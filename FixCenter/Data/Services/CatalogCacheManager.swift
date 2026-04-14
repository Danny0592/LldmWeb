import Foundation
import SwiftUI
import Combine

/// Estructura para agrupar los datos del catálogo en la persistencia local.
struct CatalogContainer: Codable {
    let brands: [DeviceBrand]
    let models: [DeviceSpecificModel]
    let lastSyncDate: Date
}

/// Actor que gestiona la caché local del catálogo de dispositivos.
/// Se encarga de persistir los datos descargados y proveer búsquedas rápidas.
@MainActor
class CatalogCacheManager: ObservableObject {
    /// Lista de marcas en caché.
    @Published private(set) var brands: [DeviceBrand] = []
    /// Lista de modelos en caché.
    @Published private(set) var models: [DeviceSpecificModel] = []
    /// Fecha de la última sincronización exitosa.
    @Published private(set) var lastSyncDate: Date? = nil
    
    private let cacheKey = "device_catalog_cache"
    
    init() {
        loadFromLocalStorage()
    }
    
    /// Actualiza la caché con datos nuevos y los persiste.
    func updateCache(brands: [DeviceBrand], models: [DeviceSpecificModel]) {
        self.brands = brands
        self.models = models
        self.lastSyncDate = Date()
        saveToLocalStorage()
    }
    
    /// Obtiene las marcas filtradas por categoría.
    func getBrands(for categoryId: String) -> [DeviceBrand] {
        brands.filter { $0.categories.contains(categoryId) }
            .sorted { $0.name < $1.name }
    }
    
    /// Obtiene los modelos filtrados por marca y categoría.
    func getModels(for brandId: String, categoryId: String) -> [DeviceSpecificModel] {
        models.filter { $0.brand_id == brandId && $0.category_id == categoryId }
            .sorted { $0.name < $1.name }
    }
    
    /// Guarda el estado actual en UserDefaults.
    private func saveToLocalStorage() {
        let container = CatalogContainer(brands: brands, models: models, lastSyncDate: lastSyncDate ?? Date())
        if let encoded = try? JSONEncoder().encode(container) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    /// Carga los datos guardados previamente de UserDefaults.
    private func loadFromLocalStorage() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let container = try? JSONDecoder().decode(CatalogContainer.self, from: data) else {
            return
        }
        self.brands = container.brands
        self.models = container.models
        self.lastSyncDate = container.lastSyncDate
    }
}
