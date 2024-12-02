import SwiftUI

func getImage(url: URL) async throws -> UIImage {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse else {
        throw URLError(.badURL)
    }
    if response.statusCode == 200,
       let image = UIImage(data: data) {
        return image
    } else {
        throw URLError(.cannotDecodeContentData)
    }
}

let url = URL(string: "https://www.themoviedb.org/t/p/w440_and_h660_face/osYbtvqjMUhEXgkuFJOsRYVpq6N.jpg")!

let task = Task {
    async let imagen = getImage(url: url)
    
    let task = Task {
        try await getImage(url: url)
    }
    
    switch await task.result {
        case .success(let imagen):
            print(imagen)
            imagen
        case .failure(let error):
            print(error)
    }
    
    do {
        let poster = try await task.value
    } catch {
        print(error)
    }
    
    try await imagen
    
    let task2 = Task { () -> UIImage? in
        do {
            return try await getImage(url: url)
        } catch {
            print(error)
            return nil
        }
    }
    
    if let poster = await task2.value {
        print(poster)
        poster
    }
}
