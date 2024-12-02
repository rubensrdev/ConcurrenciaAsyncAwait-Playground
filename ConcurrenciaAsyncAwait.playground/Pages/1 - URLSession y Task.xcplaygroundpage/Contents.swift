import Foundation

let url = URL(string: "https://i.blogs.es/c31a61/dragon-ball-daima-2024-octubre/1366_2000.jpeg")

// Configurando URLSession
var config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 5 // Tiempo de espera de 5 seg

let session = URLSession(configuration: config)

// Configurando la petición
var request = URLRequest(url: url!)
request.httpMethod = "GET"

// Creación de la Task
let task = Task { () -> Data? in
    do {
        // intento obtener data de la request
        let (data, _) = try await session.data(for: request)
        return data
    } catch {
        print(error)
        return nil
    }
}

