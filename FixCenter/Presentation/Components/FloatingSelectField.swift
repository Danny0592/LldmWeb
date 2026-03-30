import SwiftUI

/// Un campo de selección que imita el estilo de `FloatingTextField` pero funciona como un botón.
struct FloatingSelectField: View {
    let title: String
    let text: String
    let placeholder: String
    let action: () -> Void
    var icon: String? = nil
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(disabled ? .gray : .blue)
                
                HStack(spacing: 12) {
                    if let iconName = icon {
                        Image(systemName: iconName)
                            .foregroundColor((disabled ? Color.gray : Color.blue).opacity(0.8))
                            .font(.system(size: 18))
                            .frame(width: 20)
                    }
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray.opacity(0.6))
                    } else {
                        Text(text)
                            .foregroundColor(disabled ? .gray : .primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 14))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(disabled ? 0.4 : 0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
    }
}
