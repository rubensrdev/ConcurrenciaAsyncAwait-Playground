import SwiftUI

let jsonImages = URL(string: "https://acoding.academy/testData/testImages.json")!

struct Images: Codable {
    let images: [URL]
}

func getImagesSimple(url: URL) async throws -> UIImage? {
    let (data, _) = try await URLSession.shared.data(from: url)
    return UIImage(data: data)
}

/// Descarga la imagenes de forma serializada (una a una)
func getImagesSerialize(jsonURL: URL) async throws -> [UIImage] {
    var result: [UIImage] = []
    let (data, _) = try await URLSession.shared.data(from: jsonURL)
    let urls = try JSONDecoder().decode(Images.self, from: data).images
    for url in urls {
        if let imagen = try await getImagesSimple(url: url) {
            result.append(imagen)
        }
    }
    return result
}

/// Con esta función la descarga será de forma concurrente
/// utilizando los Grupos de Tareas
func getImagesConcurrent(jsonURL: URL) async throws -> [UIImage] {
    var result: [UIImage] = []
    
    let (data, _) = try await URLSession.shared.data(from: jsonURL)
    let urls = try JSONDecoder().decode(Images.self, from: data).images
    
    try await withThrowingTaskGroup(of: UIImage?.self) { group in
        for url in urls {
            group.addTask {
                try await getImagesSimple(url: url)
            }
        }
        
        for try await image in group.compactMap({ $0 })  {
            result.append(image)
        }
    }
    
    return result
}

Task {
    let images = try await getImagesConcurrent(jsonURL: jsonImages)
    images
}

