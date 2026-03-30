import SwiftUI

/// Un componente visual para marcar rápidamente el estado de diferentes componentes (Checklist).
struct DiagnosticChecklistView: View {
    @Binding var diagnostics: [DiagnosticItem]
    var deviceTypeName: String
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checklist de Recepción (\(deviceTypeName))")
                .font(.headline)
                .foregroundColor(.primary)
            
            if diagnostics.isEmpty {
                Text("No hay puntos de diagnóstico para este dispositivo.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach($diagnostics) { $item in
                        DiagnosticButton(item: $item)
                    }
                }
            }
        }
    }
}

/// Botón individual que alterna entre los diferentes estados de diagnóstico.
struct DiagnosticButton: View {
    @Binding var item: DiagnosticItem
    
    var body: some View {
        Button(action: cycleStatus) {
            HStack(spacing: 8) {
                Image(systemName: item.status.icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
                
                Text(item.name)
                    .font(.footnote)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(textColor)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: item.status)
    }
    
    /// Alterna el estado: No probado -> Funciona -> Falla -> No probado
    private func cycleStatus() {
        switch item.status {
        case .notTested:
            item.status = .pass
        case .pass:
            item.status = .fail
        case .fail:
            item.status = .notTested
        }
    }
    
    // MARK: - Estilos Dinámicos
    
    private var iconColor: Color {
        switch item.status {
        case .notTested: return .gray.opacity(0.6)
        case .pass: return .green
        case .fail: return .red
        }
    }
    
    private var textColor: Color {
        switch item.status {
        case .notTested: return .primary.opacity(0.8)
        case .pass, .fail: return .primary
        }
    }
    
    private var backgroundColor: Color {
        switch item.status {
        case .notTested: return Color.white.opacity(0.8)
        case .pass: return Color.green.opacity(0.1)
        case .fail: return Color.red.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        switch item.status {
        case .notTested: return Color.gray.opacity(0.3)
        case .pass: return Color.green.opacity(0.5)
        case .fail: return Color.red.opacity(0.5)
        }
    }
}
