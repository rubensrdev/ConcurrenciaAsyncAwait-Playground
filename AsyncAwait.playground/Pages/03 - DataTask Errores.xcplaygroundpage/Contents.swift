import SwiftUI

let url = URL(string: "https://www.themoviedb.org/t/p/w440_and_h660_face/osYbtvqjMUhEgkuFJOsRYVpq6N.jpg")!

enum NetworkError: LocalizedError {
    case general(Error)
    case status(Int)
    case dataNotValid
    case nonHTTP
    
    var errorDescription: String? {
        switch self {
            case .general(let error):
                "Error general: \(error.localizedDescription)."
            case .status(let int):
                "Error de status: \(int)."
            case .dataNotValid:
                "Error, dato no válido."
            case .nonHTTP:
                "No es una conexión HTTP."
        }
    }
}

func getImage(url: URL) async throws(NetworkError) -> UIImage {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.nonHTTP
        }
        if response.statusCode == 200 {
            if let image = UIImage(data: data) {
                return image
            } else {
                throw NetworkError.dataNotValid
            }
        } else {
            throw NetworkError.status(response.statusCode)
        }
    } catch let error as NetworkError {
        throw error
    } catch {
        throw .general(error)
    }
}

Task {
    do {
        let image = try await getImage(url: url)
        image
    } catch {
        print(error.localizedDescription)
    }
}
