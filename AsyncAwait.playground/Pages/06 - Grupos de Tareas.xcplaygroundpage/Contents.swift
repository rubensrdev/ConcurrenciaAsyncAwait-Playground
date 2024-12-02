import SwiftUI

let jsonImages = URL(string: "https://acoding.academy/testData/testImages.json")!

struct Images: Codable {
    let images: [URL]
}

func getImageSimple(url: URL) async throws -> UIImage? {
    let (data, _) = try await URLSession.shared.data(from: url)
    return UIImage(data: data)
}

func getImagesSerialize(jsonURL: URL) async throws -> [UIImage] {
    var result: [UIImage] = []
    
    let (data, _) = try await URLSession.shared.data(from: jsonURL)
    let urls = try JSONDecoder().decode(Images.self, from: data).images
    
    for url in urls {
        if let imagen = try await getImageSimple(url: url) {
            result.append(imagen)
        }
    }
    
    return result
}

func getImagesConcurrent(jsonURL: URL) async throws -> [UIImage] {
    var result: [UIImage] = []
    
    let (data, _) = try await URLSession.shared.data(from: jsonURL)
    let urls = try JSONDecoder().decode(Images.self, from: data).images
    
    try await withThrowingTaskGroup(of: UIImage?.self) { group in
        for url in urls {
            group.addTask {
                try await getImageSimple(url: url)
            }
        }
        
        for try await image in group.compactMap({ $0 }) {
            result.append(image)
        }
    }
    
    return result
}

func getImagesConcurrentReturning(jsonURL: URL) async throws -> [UIImage] {
    let (data, _) = try await URLSession.shared.data(from: jsonURL)
    let urls = try JSONDecoder().decode(Images.self, from: data).images
    
    return try await withThrowingTaskGroup(of: UIImage?.self,
                                           returning: [UIImage].self) { group in
        for url in urls {
            group.addTask {
                try await getImageSimple(url: url)
            }
        }
        
        var result: [UIImage] = []
        result.reserveCapacity(urls.count)
        
        return try await group.compactMap { $0 }
            .reduce(into: result) { partialResult, image in
                partialResult.append(image)
            }
    }
}

Task {
    let images = try await getImagesConcurrentReturning(jsonURL: jsonImages)
    images
}
