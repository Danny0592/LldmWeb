//
//  Repair.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Representa una orden de reparación integral en FixCenter.
/// Centraliza la información del cliente, el dispositivo, el estado del trabajo y la facturación.
struct Repair: Identifiable, Codable, Hashable {
    /// Identificador único de la reparación (Doc ID en Firestore).
    var id: String
    /// Folio o ticket de servicio (opcional).
    var folio: String?
    /// Información del cliente propietario.
    var customer: Customer
    /// Detalles del dispositivo a reparar.
    var device: Device
    /// Descripción del problema reportado por el cliente.
    var problemDescription: String
    /// Técnico encargado de realizar el trabajo.
    var assignedTechnician: String
    /// Estado actual del flujo de reparación.
    var status: RepairStatus
    /// Fecha en la que se recibió el equipo.
    var receivedDate: Date
    /// Fecha estimada o real de entrega (opcional).
    var deliveryDate: Date?
    /// Fotografías del estado inicial del equipo.
    var initialPhotos: [Data]
    /// Fotografías del trabajo finalizado.
    var finalPhotos: [Data]
    /// Detalle del trabajo técnico realizado.
    var workPerformed: String
    /// Notas internas o aclaraciones adicionales.
    var notes: String
    /// Costo total de la reparación (opcional).
    var price: Double?
    /// Lista de diagnóstico inicial basado en checklist.
    var diagnostics: [DiagnosticItem]
    
    /// Inicializa una nueva orden de reparación.
    /// - Parameters:
    ///   - id: ID único.
    ///   - folio: Folio de servicio.
    ///   - customer: Datos del cliente.
    ///   - device: Datos del equipo.
    ///   - problemDescription: Qué falla presenta.
    ///   - assignedTechnician: Quién lo repara.
    ///   - status: Estado inicial (por defecto .received).
    ///   - receivedDate: Cuándo entra al taller.
    ///   - deliveryDate: Cuándo se entrega.
    ///   - initialPhotos: Fotos de entrada.
    ///   - finalPhotos: Fotos de salida.
    ///   - workPerformed: Qué se le hizo.
    ///   - notes: Comentarios extra.
    ///   - price: Precio final.
    init(
        id: String = UUID().uuidString,
        folio: String? = nil,
        customer: Customer = Customer(),
        device: Device = Device(),
        problemDescription: String = "",
        assignedTechnician: String = "",
        status: RepairStatus = .received,
        receivedDate: Date = Date(),
        deliveryDate: Date? = nil,
        initialPhotos: [Data] = [],
        finalPhotos: [Data] = [],
        workPerformed: String = "",
        notes: String = "",
        price: Double? = nil,
        diagnostics: [DiagnosticItem] = []
    ) {
        self.id = id
        self.folio = folio
        self.customer = customer
        self.device = device
        self.problemDescription = problemDescription
        self.assignedTechnician = assignedTechnician
        self.status = status
        self.receivedDate = receivedDate
        self.deliveryDate = deliveryDate
        self.initialPhotos = initialPhotos
        self.finalPhotos = finalPhotos
        self.workPerformed = workPerformed
        self.notes = notes
        self.price = price
        self.diagnostics = diagnostics
    }
    
    enum CodingKeys: String, CodingKey {
        case id, folio, customer, device, problemDescription, assignedTechnician, status, receivedDate, deliveryDate, initialPhotos, finalPhotos, workPerformed, notes, price, diagnostics
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Nota: Firestore guarda el ID como documentID, no como campo dentro del documento.
        // Se usa decodeIfPresent aquí y se sobreescribe con documentID en fetchRepairs.
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        folio = try container.decodeIfPresent(String.self, forKey: .folio)
        customer = try container.decode(Customer.self, forKey: .customer)
        device = try container.decode(Device.self, forKey: .device)
        problemDescription = try container.decodeIfPresent(String.self, forKey: .problemDescription) ?? ""
        assignedTechnician = try container.decodeIfPresent(String.self, forKey: .assignedTechnician) ?? ""
        status = try container.decode(RepairStatus.self, forKey: .status)

        // receivedDate y deliveryDate pueden estar guardadas como Timestamp (nuevo) o
        // como String ISO8601 (registros antiguos). Manejamos ambos casos.
        receivedDate = Self.decodeDate(from: container, forKey: .receivedDate) ?? Date()
        deliveryDate = Self.decodeDate(from: container, forKey: .deliveryDate)

        initialPhotos = try container.decodeIfPresent([Data].self, forKey: .initialPhotos) ?? []
        finalPhotos = try container.decodeIfPresent([Data].self, forKey: .finalPhotos) ?? []
        workPerformed = try container.decodeIfPresent(String.self, forKey: .workPerformed) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        diagnostics = try container.decodeIfPresent([DiagnosticItem].self, forKey: .diagnostics) ?? []
    }

    /// Intenta decodificar una fecha como Timestamp de Firebase o como String ISO8601.
    private static func decodeDate(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Date? {
        // Intento 1: Timestamp de Firestore (formato nativo — el más común para registros nuevos)
        if let date = try? container.decodeIfPresent(Date.self, forKey: key) {
            return date
        }
        // Intento 2: String ISO8601 (registros anteriores guardados con JSONEncoder)
        if let isoString = try? container.decodeIfPresent(String.self, forKey: key) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: isoString) { return date }
            formatter.formatOptions = .withInternetDateTime
            return formatter.date(from: isoString)
        }
        return nil
    }
}

extension Repair {
    /// Número de días transcurridos desde que se recibió el equipo.
    var daysInRepair: Int {
        Calendar.current.dateComponents([.day], from: receivedDate, to: Date()).day ?? 0
    }
    
    /// Indica si la reparación ha excedido el tiempo estándar (7 días) y sigue pendiente.
    var isOverdue: Bool {
        daysInRepair > 7 && status != .delivered && status != .cancelled
    }
    
    /// Representación amigable del precio con formato de moneda (MXN).
    var formattedPrice: String {
        guard let price = price else { return "No especificado" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}


