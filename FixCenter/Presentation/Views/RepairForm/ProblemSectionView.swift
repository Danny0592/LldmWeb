//
//  ProblemSectionView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Sección del formulario para describir el problema técnico y capturar fotos iniciales.
struct ProblemSectionView: View {
    /// ViewModel compartido del formulario.
    @ObservedObject var viewModel: RepairFormViewModel
    @FocusState private var focusedField: RepairFormField?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    /// Checklist de Recepción
                    GlassCard {
                        DiagnosticChecklistView(
                            diagnostics: $viewModel.repair.diagnostics,
                            deviceTypeName: viewModel.repair.device.type.rawValue
                        )
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Descripción adicional del problema")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $viewModel.repair.problemDescription)
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
                                .focused($focusedField, equals: .problemDescription)
                                .id(RepairFormField.problemDescription)
                        }
                    }
                    
                    GlassCard {
                        ImagePickerView(
                            selectedImages: $viewModel.initialImages,
                            title: "Fotos del daño inicial",
                            maxImages: 10
                        )
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
    ProblemSectionView(
        viewModel: RepairFormViewModel(
            repository: RepairRepositoryImpl(storageService: LocalStorageService()),
            imageService: ImageStorageService(),
            cacheManager: CatalogCacheManager()
        )
    )
}
