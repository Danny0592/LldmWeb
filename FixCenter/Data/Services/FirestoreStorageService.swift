import Foundation
import FirebaseFirestore

/// Implementación de almacenamiento en la nube basada en `Firestore`.
/// Gestiona la persistencia de las reparaciones sincronizándolas con la base de datos de Firebase.
class FirestoreStorageService: StorageService {
    private var db: Firestore { Firestore.firestore() }
    private let collectionName = "repairs"
    private var customerService: FirestoreCustomerService { FirestoreCustomerService() }
    
    /// Guarda o actualiza una reparación en Firestore.
    /// También gestiona la lógica de "Encontrar o crear cliente" para mantener la consistencia.
    func saveRepair(_ repair: Repair) async throws {
        var finalRepair = repair
        
        // 1. Lógica inteligente de Cliente (Encontrar o Crear)
        if let existingCustomer = try await customerService.findCustomer(byPhone: repair.customer.phone) {
            // El cliente ya existe: Usamos su ID y actualizamos métricas
            finalRepair.customer.id = existingCustomer.id
            let newTotal = (existingCustomer.totalRepairs ?? 0) + 1
            try await customerService.updateCustomerMetrics(id: existingCustomer.id, total: newTotal)
            finalRepair.customer.totalRepairs = newTotal
        } else {
            // El cliente es nuevo: Lo registramos primero en Firestore
            var newCustomer = repair.customer
            newCustomer.totalRepairs = 1
            newCustomer.status = "Nuevo"
            newCustomer.lastVisit = Date()
            
            let newCustomerId = try await customerService.createCustomer(newCustomer)
            finalRepair.customer.id = newCustomerId
            finalRepair.customer.totalRepairs = 1
        }
        
        // 2. Guardar la reparación final
        try db.collection(collectionName).document(finalRepair.id).setData(from: finalRepair)
    }
    
    /// Obtiene la lista completa de reparaciones desde Firestore.
    func fetchRepairs() async throws -> [Repair] {
        let snapshot = try await db.collection(collectionName)
            .order(by: "receivedDate", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            do {
                var repair = try document.data(as: Repair.self)
                // El ID de Firestore no es un campo del documento, se inyecta desde documentID
                if repair.id.isEmpty {
                    repair.id = document.documentID
                }
                return repair
            } catch {
                print("⚠️ [Firestore] Error al decodificar reparación [\(document.documentID)]: \(error)")
                print("   Datos del documento: \(document.data())")
                return nil
            }
        }
    }
    
    /// Recupera una reparación individual por su ID (String).
    func fetchRepair(id: String) async throws -> Repair? {
        let document = try await db.collection(collectionName).document(id).getDocument()
        guard document.exists else { return nil }
        do {
            var repair = try document.data(as: Repair.self)
            if repair.id.isEmpty {
                repair.id = document.documentID
            }
            return repair
        } catch {
            print("⚠️ Error al decodificar reparación [\(document.documentID)]: \(error)")
            return nil
        }
    }
    
    /// Actualiza los datos de una reparación existente.
    func updateRepair(_ repair: Repair) async throws {
        try await saveRepair(repair)
    }
    
    /// Elimina una reparación de Firestore (String ID).
    func deleteRepair(id: String) async throws {
        try await db.collection(collectionName).document(id).delete()
    }
    
    /// Busca entre las reparaciones almacenadas basándose en un criterio de texto.
    func searchRepairs(query: String) async throws -> [Repair] {
        // Nota: Firestore no soporta búsqueda de texto completo "fuzzy" nativa, 
        // por lo que descargamos y filtramos localmente para esta versión simple.
        let allRepairs = try await fetchRepairs()
        let lowerQuery = query.lowercased()
        
        return allRepairs.filter { repair in
            (repair.folio?.lowercased().contains(lowerQuery) ?? false) ||
            repair.customer.fullName.lowercased().contains(lowerQuery) ||
            repair.device.brand.lowercased().contains(lowerQuery) ||
            repair.device.model.lowercased().contains(lowerQuery) ||
            repair.problemDescription.lowercased().contains(lowerQuery)
        }
    }
    
    /// Filtra la lista de reparaciones por su estatus.
    func filterRepairs(by status: RepairStatus) async throws -> [Repair] {
        let snapshot = try await db.collection(collectionName)
            .whereField("status", isEqualTo: status.rawValue)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Repair.self)
        }
    }
}
