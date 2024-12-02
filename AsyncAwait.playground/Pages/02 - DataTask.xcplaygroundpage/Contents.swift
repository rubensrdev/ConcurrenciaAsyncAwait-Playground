import SwiftUI

let url = URL(string: "https://www.themoviedb.org/t/p/w440_and_h660_face/osYbtvqjMUhEXgkuFJOsRYVpq6N.jpg")!

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

Task {
    let image = try await getImage(url: url)
    image
    print(image)
}
