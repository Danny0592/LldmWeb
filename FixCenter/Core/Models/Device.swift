//
//  Device.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Representa el dispositivo que requiere reparación.
struct Device: Identifiable, Codable, Hashable {
    /// Identificador único del dispositivo.
    var id: String
    /// Tipo de dispositivo (ej. Teléfono, Tablet, etc.).
    var type: DeviceType
    /// Marca del fabricante.
    var brand: String
    /// Modelo específico del dispositivo.
    var model: String
    /// Número de serie o IMEI.
    var serialNumber: String
    /// Contraseña o patrón de desbloqueo para pruebas.
    var password: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, brand, model, serialNumber, password
    }
    
    /// Inicializa un nuevo dispositivo.
    init(
        id: String = UUID().uuidString,
        type: DeviceType = .phone,
        brand: String = "",
        model: String = "",
        serialNumber: String = "",
        password: String = ""
    ) {
        self.id = id
        self.type = type
        self.brand = brand
        self.model = model
        self.serialNumber = serialNumber
        self.password = password
    }
    
    /// Decoder personalizado para manejar campos opcionales de Firestore.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        type = try container.decodeIfPresent(DeviceType.self, forKey: .type) ?? .phone
        brand = try container.decodeIfPresent(String.self, forKey: .brand) ?? ""
        model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
        serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber) ?? ""
        password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
    }
}

extension Device {
    /// Nombre formateado para mostrar (Marca + Modelo).
    var displayName: String {
        if brand.isEmpty && model.isEmpty {
            return type.rawValue
        }
        return "\(brand) \(model)".trimmingCharacters(in: .whitespaces)
    }
}
