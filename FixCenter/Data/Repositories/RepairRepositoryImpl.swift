//
//  RepairRepositoryImpl.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Implementación concreta del repositorio de reparaciones.
/// Utiliza un `StorageService` para delegar las operaciones de persistencia.
class RepairRepositoryImpl: RepairRepository {
    /// Servicio de almacenamiento subyacente.
    private let storageService: StorageService
    
    /// Inicializa el repositorio con un servicio de almacenamiento.
    /// - Parameter storageService: El servicio que manejará los datos reales.
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    /// Guarda una nueva reparación.
    func saveRepair(_ repair: Repair) async throws {
        try await storageService.saveRepair(repair)
    }
    
    /// Obtiene todas las reparaciones.
    func fetchRepairs() async throws -> [Repair] {
        try await storageService.fetchRepairs()
    }
    
    /// Busca una reparación por ID (String).
    func fetchRepair(id: String) async throws -> Repair? {
        try await storageService.fetchRepair(id: id)
    }
    
    /// Actualiza una reparación.
    func updateRepair(_ repair: Repair) async throws {
        try await storageService.updateRepair(repair)
    }
    
    /// Elimina una reparación por ID (String).
    func deleteRepair(id: String) async throws {
        try await storageService.deleteRepair(id: id)
    }
    
    /// Busca reparaciones por texto.
    func searchRepairs(query: String) async throws -> [Repair] {
        try await storageService.searchRepairs(query: query)
    }
    
    /// Filtra reparaciones por estado.
    func filterRepairs(by status: RepairStatus) async throws -> [Repair] {
        try await storageService.filterRepairs(by: status)
    }
}
