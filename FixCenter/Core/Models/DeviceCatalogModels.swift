import Foundation

/// Modelo que representa una marca de dispositivo descargada de Firestore.
struct DeviceBrand: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var categories: [String]
}

/// Modelo que representa un modelo específico descargado de Firestore.
struct DeviceSpecificModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var brand_id: String
    var category_id: String
}
