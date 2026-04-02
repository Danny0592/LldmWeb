import Foundation
import FirebaseFirestore

/// Clase encargada de las operaciones directas con la colección de clientes en Firestore.
class FirestoreCustomerService {
    private var db: Firestore { Firestore.firestore() }
    private let collectionName = "customers"
    
    /// Busca un cliente por su número de teléfono.
    /// - Parameter phone: Teléfono a buscar.
    /// - Returns: El cliente encontrado o nil si no existe.
    func findCustomer(byPhone phone: String) async throws -> Customer? {
        let snapshot = try await db.collection(collectionName)
            .whereField("phone", isEqualTo: phone)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            return nil
        }
        
        var customer = try document.data(as: Customer.self)
        // Asegurar que el ID provenga del documento de Firestore, no del UUID autogenerado
        customer.id = document.documentID
        return customer
    }
    
    /// Crea un nuevo cliente en Firestore.
    /// - Parameter customer: Los datos del cliente a registrar.
    /// - Returns: El ID generado para el nuevo cliente.
    func createCustomer(_ customer: Customer) async throws -> String {
        let docRef = try db.collection(collectionName).addDocument(from: customer)
        return docRef.documentID
    }
    
    /// Actualiza las métricas de un cliente (total de reparaciones y estatus).
    /// - Parameters:
    ///   - id: ID del documento del cliente.
    ///   - total: Nuevo total de reparaciones.
    func updateCustomerMetrics(id: String, total: Int) async throws {
        let status: String
        if total >= 5 {
            status = "VIP"
        } else if total >= 2 {
            status = "Frecuente"
        } else {
            status = "Nuevo"
        }
        
        try await db.collection(collectionName).document(id).updateData([
            "totalRepairs": total,
            "status": status,
            "lastVisit": Timestamp(date: Date())
        ])
    }
}
