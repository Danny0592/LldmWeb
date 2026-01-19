//
//  PDFService.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import Foundation

struct SongResponse: Codable {
    let id: String
    let titulo: String
    let url: String
    let categoria: String?  // Categoría/tema de la canción (opcional para compatibilidad)
}

class PDFService {
    private let baseURL = "https://lldmcantos-server.onrender.com"
    
    static let shared = PDFService()
    
    private init() {}
    
    // Obtener la lista de canciones desde el servidor
    func fetchSongs() async throws -> [SongResponse] {
        guard let url = URL(string: "\(baseURL)/canciones") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 35.0 // Timeout de 35 segundos (Render puede tardar en "despertar")
        request.cachePolicy = .reloadIgnoringLocalCacheData // No usar cache
        // Configurar para permitir conexiones celulares
        request.allowsCellularAccess = true
        request.allowsConstrainedNetworkAccess = true
        request.allowsExpensiveNetworkAccess = true
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NSError(domain: "PDFService", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "Error del servidor: código \(httpResponse.statusCode)"
                ])
            }
            
            let songs = try JSONDecoder().decode([SongResponse].self, from: data)
            return songs
        } catch let error as URLError {
            // Proporcionar mensajes de error más descriptivos
            switch error.code {
            case .notConnectedToInternet:
                throw NSError(domain: "PDFService", code: error.code.rawValue, userInfo: [
                    NSLocalizedDescriptionKey: "Sin conexión a internet. Verifica tu Wi-Fi."
                ])
            case .cannotConnectToHost, .timedOut:
                let isLocal = baseURL.contains("localhost") || baseURL.contains("192.168") || baseURL.contains("127.0.0.1")
                let errorMsg = isLocal 
                    ? "No se puede conectar al servidor en \(baseURL). Verifica:\n1. Que el servidor esté corriendo\n2. Que tu Mac e iPhone estén en la misma red Wi-Fi\n3. Que la IP sea correcta"
                    : "No se puede conectar al servidor en \(baseURL). Verifica:\n1. Que tengas conexión a internet\n2. Que el servidor esté en línea\n3. Que la URL sea correcta"
                throw NSError(domain: "PDFService", code: error.code.rawValue, userInfo: [
                    NSLocalizedDescriptionKey: errorMsg
                ])
            default:
                throw NSError(domain: "PDFService", code: error.code.rawValue, userInfo: [
                    NSLocalizedDescriptionKey: "Error de conexión: \(error.localizedDescription)"
                ])
            }
        }
    }
}

