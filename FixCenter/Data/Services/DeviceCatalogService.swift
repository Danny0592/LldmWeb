import Foundation
import FirebaseFirestore

/// Protocolo que define las operaciones del catálogo de dispositivos.
protocol DeviceCatalogService {
    /// Obtiene las marcas disponibles para una categoría específica.
    func fetchBrands(for categoryId: String) async throws -> [DeviceBrand]
    
    /// Obtiene los modelos disponibles para una marca y categoría específica.
    func fetchModels(for brandId: String, categoryId: String) async throws -> [DeviceSpecificModel]
}

/// Implementación del servicio de catálogo utilizando Firebase Firestore.
class FirebaseDeviceCatalogService: DeviceCatalogService {
    private let db = Firestore.firestore()
    
    func fetchBrands(for categoryId: String) async throws -> [DeviceBrand] {
        let snapshot = try await db.collection("brands")
            .whereField("categories", arrayContains: categoryId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let id = data["id"] as? String,
                  let name = data["name"] as? String,
                  let categories = data["categories"] as? [String] else {
                return nil
            }
            return DeviceBrand(id: id, name: name, categories: categories)
        }.sorted { $0.name < $1.name }
    }
    
    func fetchModels(for brandId: String, categoryId: String) async throws -> [DeviceSpecificModel] {
        let snapshot = try await db.collection("models")
            .whereField("brand_id", isEqualTo: brandId)
            .whereField("category_id", isEqualTo: categoryId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let name = data["name"] as? String,
                  let bId = data["brand_id"] as? String,
                  let catId = data["category_id"] as? String else {
                return nil
            }
            return DeviceSpecificModel(id: document.documentID, name: name, brand_id: bId, category_id: catId)
        }.sorted { $0.name < $1.name }
    }
}
