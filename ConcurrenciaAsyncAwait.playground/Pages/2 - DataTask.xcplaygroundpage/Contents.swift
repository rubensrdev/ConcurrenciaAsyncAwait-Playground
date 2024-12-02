import SwiftUI

let url = URL(string: "https://i.blogs.es/c31a61/dragon-ball-daima-2024-octubre/1366_2000.jpeg")

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

Task {
    let image =  try await getImage(url: url!)
}
