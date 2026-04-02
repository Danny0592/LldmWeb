//
//  Customer.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation
import FirebaseFirestore

/// Representa a un cliente en el sistema de FixCenter.
struct Customer: Identifiable, Codable, Hashable {
    /// Identificador único del cliente (Id del documento en Firestore).
    var id: String
    /// Nombre completo del cliente.
    var fullName: String
    /// Número de teléfono de contacto.
    var phone: String
    /// Dirección física del cliente.
    var address: String
    /// Correo electrónico de contacto.
    var email: String
    /// Estatus de lealtad (Nuevo, Frecuente, VIP)
    var status: String?
    /// Contador total de reparaciones
    var totalRepairs: Int?
    /// Fecha de su última actividad
    var lastVisit: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, fullName, phone, address, email, status, totalRepairs, lastVisit
    }
    
    /// Inicializa un nuevo cliente.
    init(
        id: String = UUID().uuidString,
        fullName: String = "",
        phone: String = "",
        address: String = "",
        email: String = "",
        status: String? = "Nuevo",
        totalRepairs: Int? = 0,
        lastVisit: Date? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.phone = phone
        self.address = address
        self.email = email
        self.status = status
        self.totalRepairs = totalRepairs
        self.lastVisit = lastVisit
    }
    
    /// Decoder personalizado para manejar campos opcionales de Firestore.
    /// Nota: `lastVisit` se almacena en Firestore como Timestamp. El SDK de Firebase
    /// lo convierte automáticamente a `Date` cuando es el documento raíz, pero cuando
    /// es un sub-objeto (anidado dentro de `Repair`), puede llegar como String ISO8601.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status)
        totalRepairs = try container.decodeIfPresent(Int.self, forKey: .totalRepairs)
        
        // Manejo tolerante de lastVisit: puede ser Date (Timestamp convertido por Firebase SDK)
        // o String ISO8601 cuando viene como sub-objeto anidado.
        if let date = try? container.decodeIfPresent(Date.self, forKey: .lastVisit) {
            lastVisit = date
        } else if let isoString = try? container.decodeIfPresent(String.self, forKey: .lastVisit) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            lastVisit = formatter.date(from: isoString)
            if lastVisit == nil {
                // Intento secundario sin fracciones de segundo
                formatter.formatOptions = .withInternetDateTime
                lastVisit = formatter.date(from: isoString)
            }
            if lastVisit == nil {
                print("⚠️ [Customer] No se pudo parsear lastVisit: \(isoString)")
            }
        } else {
            lastVisit = nil
        }
    }
}

extension Customer {
    /// Obtiene las iniciales del nombre completo del cliente.
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if !components.isEmpty {
            return String(components[0].prefix(2)).uppercased()
        }
        return "??"
    }
}
