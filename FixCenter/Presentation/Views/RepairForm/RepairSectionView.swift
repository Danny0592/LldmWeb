//
//  RepairSectionView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Sección final del formulario para registrar la solución técnica, precio y evidencia final.
struct RepairSectionView: View {
    /// ViewModel compartido del formulario.
    @ObservedObject var viewModel: RepairFormViewModel
    @FocusState private var focusedField: RepairFormField?
    @State private var priceText: String = ""
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Técnico asignado", systemImage: "person.badge.key.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                TextField("Nombre del técnico", text: $viewModel.repair.assignedTechnician)
                                    .focused($focusedField, equals: .technician)
                                    .id(RepairFormField.technician)
                                
                                if !viewModel.repair.assignedTechnician.isEmpty && focusedField == .technician {
                                    Button(action: {
                                        viewModel.repair.assignedTechnician = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Precio de la reparación")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                TextField("0.00", text: $priceText)
                                    .keyboardType(.decimalPad)
                                    .font(.title2)
                                    .focused($focusedField, equals: .price)
                                    .id(RepairFormField.price)
                                    .onChange(of: priceText) { newValue in
                                        if let price = Double(newValue) {
                                            viewModel.repair.price = price
                                        } else if newValue.isEmpty {
                                            viewModel.repair.price = nil
                                        }
                                    }
                                    .onAppear {
                                        if let price = viewModel.repair.price {
                                            priceText = String(format: "%.2f", price)
                                        }
                                    }
                                
                                if !priceText.isEmpty && focusedField == .price {
                                    Button(action: {
                                        priceText = ""
                                        viewModel.repair.price = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Trabajo realizado")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $viewModel.repair.workPerformed)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.8))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .workPerformed)
                                .id(RepairFormField.workPerformed)
                        }
                    }
                    
                    GlassCard {
                        ImagePickerView(
                            selectedImages: $viewModel.finalImages,
                            title: "Fotos del dispositivo reparado",
                            maxImages: 10
                        )
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notas adicionales")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $viewModel.repair.notes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.8))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .notes)
                                .id(RepairFormField.notes)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .hideKeyboardOnTap()
            .onChange(of: focusedField) { newValue in
                if let field = newValue {
                    withAnimation(.spring()) {
                        proxy.scrollTo(field, anchor: UnitPoint(x: 0.5, y: 0.8))
                    }
                }
            }
        }
    }
}

#Preview {
    RepairSectionView(
        viewModel: RepairFormViewModel(
            repository: RepairRepositoryImpl(storageService: LocalStorageService()),
            imageService: ImageStorageService(),
            cacheManager: CatalogCacheManager()
        )
    )
}
