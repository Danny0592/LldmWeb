import Foundation

/// Representa el estado actual de una función o componente en el diagnóstico.
enum DiagnosticStatus: String, Codable, CaseIterable {
    case notTested = "No probado"
    case pass = "Funciona"
    case fail = "Falla"
    
    var icon: String {
        switch self {
        case .notTested: return "circle.dashed"
        case .pass: return "checkmark.circle.fill"
        case .fail: return "xmark.circle.fill"
        }
    }
}

/// Representa un elemento individual en la lista de diagnóstico.
struct DiagnosticItem: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var status: DiagnosticStatus
    
    init(id: UUID = UUID(), name: String, status: DiagnosticStatus = .notTested) {
        self.id = id
        self.name = name
        self.status = status
    }
}
