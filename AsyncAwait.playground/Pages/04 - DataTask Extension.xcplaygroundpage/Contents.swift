import SwiftUI

let url = URL(string: "https://www.themoviedb.org/t/p/w440_and_h660_face/osYbtvqjMUhEXgkuFJOsRYVpq6N.jpg")!

enum NetworkError: LocalizedError {
    case general(Error)
    case status(Int)
    case json(Error)
    case dataNotValid
    case nonHTTP
    
    var errorDescription: String? {
        switch self {
            case .general(let error):
                "Error general: \(error.localizedDescription)."
            case .status(let int):
                "Error de status: \(int)."
            case .json(let error):
                "Error JSON: \(error)"
            case .dataNotValid:
                "Error, dato no válido."
            case .nonHTTP:
                "No es una conexión HTTP."
        }
    }
}

extension URLSession {
    func getData(from url: URL) async throws(NetworkError) -> (data: Data, response: HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, response)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .general(error)
        }
    }
    
    func getData(for request: URLRequest) async throws(NetworkError) -> (data: Data, response: HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, response)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .general(error)
        }
    }
}

func getImage(url: URL) async throws(NetworkError) -> UIImage {
    let (data, response) = try await URLSession.shared.getData(from: url)
    if response.statusCode == 200 {
        if let image = UIImage(data: data) {
            return image
        } else {
            throw .dataNotValid
        }
    } else {
        throw .status(response.statusCode)
    }
}

func getJSON<T>(url: URL, type: T.Type) async throws(NetworkError) -> T where T: Codable {
    let (data, response) = try await URLSession.shared.getData(from: url)
    if response.statusCode == 200 {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw .json(error)
        }
    } else {
        throw .status(response.statusCode)
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
