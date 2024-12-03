import SwiftUI

func getImage(url: URL) async throws -> UIImage? {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse else {
        throw URLError(.badURL)
    }
    if response.statusCode == 200,
       let image = UIImage(data: data)
    {
        return image
    } else {
        throw URLError(.cannotDecodeContentData)
    }
}

let url = URL(string: "https://i.blogs.es/c31a61/dragon-ball-daima-2024-octubre/1366_2000.jpeg")!

// Distintas formas de acceder adatos en contextos asíncronos mediante Task
Task {
    async let image = getImage(url: url)
    try await image
    
    let task = Task {
        try await getImage(url: url)
    }

    switch await task.result {
        case .success(let image):
            image
        case .failure:
            print("Error")
    }
    
    do {
        let poster = try await task.value
    } catch {
        print(error)
    }
}
