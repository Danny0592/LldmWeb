//
//  RepairCard.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Una tarjeta que muestra un resumen de una orden de reparación.
/// Incluye el folio, estado, dispositivo, cliente y tiempo transcurrido.
struct RepairCard: View {
    /// La reparación cuyos datos se van a visualizar.
    let repair: Repair
    /// Acción que se dispara al tocar la tarjeta.
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        /// Insignia visual del estado (círculo pulsante).
                        StatusBadge(status: repair.status, size: 20)
                        
                        /// Folio de la reparación (si existe).
                        if let folio = repair.folio, !folio.isEmpty {
                            Text(folio)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(repair.status.color.opacity(0.15))
                                )
                                .padding(.leading, 6)
                        }
                        
                        Spacer()
                        
                        /// Etiqueta de texto con el nombre del estado.
                        Text(repair.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(repair.status.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(repair.status.color.opacity(0.15))
                            )
                    }
                    
                    // Información del dispositivo
                    HStack(spacing: 12) {
                        /// Icono del tipo de dispositivo con fondo circular.
                        ZStack {
                            Circle()
                                .fill(repair.device.type.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: repair.device.type.icon)
                                .font(.title2)
                                .foregroundColor(repair.device.type.color)
                        }
                        
                        /// Marca, modelo y cliente.
                        VStack(alignment: .leading, spacing: 4) {
                            Text(repair.device.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(repair.customer.fullName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Descripción del problema (limitada a 2 líneas)
                    if !repair.problemDescription.isEmpty {
                        Text(repair.problemDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Fecha de registro y días transcurridos
                    HStack {
                        Label(
                            repair.receivedDate.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if repair.daysInRepair >= 0 {
                            Text("\(repair.daysInRepair) días")
                                .font(.caption)
                                .foregroundColor(repair.isOverdue ? .red : .secondary)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(repair.status.color.opacity(0.3))
            )
        }
        .buttonStyle(RepairCardButtonStyle())
    }
}

/// Estilo de botón personalizado para la tarjeta de reparación.
/// Proporciona un efecto de escala sutil al ser presionado.
struct RepairCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    RepairCard(
        repair: Repair(
            folio: "FX-001",
            customer: Customer(fullName: "Juan Pérez", phone: "1234567890"),
            device: Device(type: .phone, brand: "Apple", model: "iPhone 14"),
            problemDescription: "Pantalla rota, necesita reemplazo",
            status: .repairing
        ),
        onTap: {}
    )
    .padding()
}


