
import SwiftUI

let url = URL(string: "https://i.blogs.es/c31a61/dragon-ball-daima-2024-octubre/1366_2000.jpeg")

enum NetworkError: LocalizedError {
    case general(Error)
    case status(Int)
    case dataNotValid
    case nonHTTP
    
    var errorDescription: String? {
        switch self {
        case .general(let error):
            "Error general: \(error)"
        case .status(let code):
            "Error de status: \(code)"
        case .dataNotValid:
            "Error, dato no válido"
        case .nonHTTP:
            "Error, no es una petición HTTP"
        }
        
    }
}

extension URLSession {
    /// recibe un tipo URL
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
    /// recibe un tiop Request
    func getData(from request: URLRequest) async throws(NetworkError) -> (data: Data, response: HTTPURLResponse) {
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

func getImage(url: URL) async throws(NetworkError) -> UIImage? {
    let (data, response) = try await URLSession.shared.getData(from: url)
    if response.statusCode == 200
    {
        if let image = UIImage(data: data) {
            return image
        } else {
            throw .dataNotValid
        }
    } else {
        throw .status(response.statusCode)
    }
}

let task = Task {
    let image =  try await getImage(url: url!)
}


