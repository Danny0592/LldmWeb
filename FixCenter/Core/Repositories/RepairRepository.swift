//
//  RepairRepository.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Protocolo que define las operaciones de persistencia y búsqueda para las reparaciones.
/// Sirve como abstracción para permitir diferentes implementaciones (Local, API, etc.).
protocol RepairRepository {
    /// Guarda una nueva reparación en el almacenamiento.
    /// - Parameter repair: La reparación a guardar.
    func saveRepair(_ repair: Repair) async throws
    
    /// Recupera todas las reparaciones registradas.
    /// - Returns: Una lista de todas las reparaciones.
    func fetchRepairs() async throws -> [Repair]
    
    /// Obtiene una reparación específica por su identificador único.
    /// - Parameter id: ID de la reparación (String).
    /// - Returns: La reparación encontrada o nil si no existe.
    func fetchRepair(id: String) async throws -> Repair?
    
    /// Actualiza la información de una reparación existente.
    /// - Parameter repair: La reparación con los datos actualizados.
    func updateRepair(_ repair: Repair) async throws
    
    /// Elimina una reparación del sistema.
    /// - Parameter id: Identificador de la reparación a eliminar (String).
    func deleteRepair(id: String) async throws
    
    /// Realiza una búsqueda de reparaciones basada en un texto.
    /// - Parameter query: Texto de búsqueda (nombre, folio, etc.).
    /// - Returns: Lista de reparaciones que coinciden con los criterios.
    func searchRepairs(query: String) async throws -> [Repair]
    
    /// Filtra las reparaciones según su estado actual.
    /// - Parameter status: El estado por el cual filtrar.
    /// - Returns: Lista de reparaciones con el estado solicitado.
    func filterRepairs(by status: RepairStatus) async throws -> [Repair]
}
