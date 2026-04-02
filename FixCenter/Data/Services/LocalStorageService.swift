//
//  LocalStorageService.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Implementación de almacenamiento local basada en `UserDefaults`.
/// Gestiona la persistencia de las reparaciones serializándolas a formato JSON.
class LocalStorageService: StorageService {
    /// Llave utilizada para almacenar las reparaciones en `UserDefaults`.
    private let repairsKey = "saved_repairs"
    
    /// Guarda o actualiza una reparación en la base de datos local.
    func saveRepair(_ repair: Repair) async throws {
        var repairs = try await fetchRepairs()
        if let index = repairs.firstIndex(where: { $0.id == repair.id }) {
            repairs[index] = repair
        } else {
            repairs.append(repair)
        }
        try saveRepairs(repairs)
    }
    
    /// Obtiene la lista completa de reparaciones guardadas.
    func fetchRepairs() async throws -> [Repair] {
        guard let data = UserDefaults.standard.data(forKey: repairsKey) else {
            return []
        }
        return try JSONDecoder().decode([Repair].self, from: data)
    }
    
    /// Recupera una reparación individual por su ID (String).
    func fetchRepair(id: String) async throws -> Repair? {
        let repairs = try await fetchRepairs()
        return repairs.first { $0.id == id }
    }
    
    /// Actualiza los datos de una reparación existente.
    func updateRepair(_ repair: Repair) async throws {
        try await saveRepair(repair)
    }
    
    /// Elimina una reparación de la lista local (String ID).
    func deleteRepair(id: String) async throws {
        var repairs = try await fetchRepairs()
        repairs.removeAll { $0.id == id }
        try saveRepairs(repairs)
    }
    
    /// Filtra las reparaciones según criterios de búsqueda (Folio, Cliente, Dispositivo, Problema).
    func searchRepairs(query: String) async throws -> [Repair] {
        let repairs = try await fetchRepairs()
        let lowerQuery = query.lowercased()
        return repairs.filter { repair in
            (repair.folio?.lowercased().contains(lowerQuery) ?? false) ||
            repair.customer.fullName.lowercased().contains(lowerQuery) ||
            repair.device.brand.lowercased().contains(lowerQuery) ||
            repair.device.model.lowercased().contains(lowerQuery) ||
            repair.problemDescription.lowercased().contains(lowerQuery)
        }
    }
    
    /// Filtra la lista de reparaciones por su estatus.
    func filterRepairs(by status: RepairStatus) async throws -> [Repair] {
        let repairs = try await fetchRepairs()
        return repairs.filter { $0.status == status }
    }
    
    /// Método privado para persistir la colección completa en `UserDefaults`.
    private func saveRepairs(_ repairs: [Repair]) throws {
        let data = try JSONEncoder().encode(repairs)
        UserDefaults.standard.set(data, forKey: repairsKey)
    }
}


