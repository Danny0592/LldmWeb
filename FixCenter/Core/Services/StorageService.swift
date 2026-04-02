//
//  StorageService.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation

/// Protocolo que define las capacidades de almacenamiento persistente para las reparaciones.
/// Esta capa se encarga de la comunicación directa con la base de datos o sistema de archivos.
protocol StorageService {
    /// Persiste una nueva reparación.
    /// - Parameter repair: El objeto de reparación a guardar.
    func saveRepair(_ repair: Repair) async throws
    
    /// Recupera todas las reparaciones del almacenamiento.
    /// - Returns: Lista de reparaciones encontradas.
    func fetchRepairs() async throws -> [Repair]
    
    /// Busca una reparación específica por su ID.
    /// - Parameter id: Identificador único (String).
    /// - Returns: La reparación encontrada o nil.
    func fetchRepair(id: String) async throws -> Repair?
    
    /// Sobrescribe los datos de una reparación existente.
    /// - Parameter repair: La reparación con datos actualizados.
    func updateRepair(_ repair: Repair) async throws
    
    /// Remueve permanentemente una reparación del almacenamiento.
    /// - Parameter id: ID de la reparación (String).
    func deleteRepair(id: String) async throws
    
    /// Busca entre las reparaciones almacenadas basándose en un criterio de texto.
    /// - Parameter query: Texto a buscar.
    /// - Returns: Reparaciones que coinciden con la búsqueda.
    func searchRepairs(query: String) async throws -> [Repair]
    
    /// Filtra la colección de reparaciones según su estado.
    /// - Parameter status: Estado de reparación deseado.
    /// - Returns: Lista de reparaciones filtradas.
    func filterRepairs(by status: RepairStatus) async throws -> [Repair]
}
