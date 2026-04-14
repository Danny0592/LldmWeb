//
//  CustomerSectionView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Sección del formulario que recolecta los datos personales del cliente.
struct CustomerSectionView: View {
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
                    
                    GlassCard {
                        VStack(spacing: 20) {
                            FloatingTextField(
                                title: "Nombre completo",
                                text: $viewModel.repair.customer.fullName,
                                placeholder: "Ej: Juan Pérez",
                                focusState: $focusedField,
                                focusValue: .customerName
                            )
                            .id(RepairFormField.customerName)
                            
                            FloatingTextField(
                                title: "Teléfono",
                                text: $viewModel.repair.customer.phone,
                                placeholder: "Ej: +52 123 456 7890",
                                keyboardType: .phonePad,
                                focusState: $focusedField,
                                focusValue: .customerPhone
                            )
                            .id(RepairFormField.customerPhone)
                            
                            FloatingTextField(
                                title: "Dirección",
                                text: $viewModel.repair.customer.address,
                                placeholder: "Ej: Calle Principal 123",
                                focusState: $focusedField,
                                focusValue: .customerAddress
                            )
                            .id(RepairFormField.customerAddress)
                            
                            FloatingTextField(
                                title: "Correo electrónico",
                                text: $viewModel.repair.customer.email,
                                placeholder: "Ej: juan@example.com",
                                keyboardType: .emailAddress,
                                focusState: $focusedField,
                                focusValue: .customerEmail
                            )
                            .id(RepairFormField.customerEmail)
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
    CustomerSectionView(
        viewModel: RepairFormViewModel(
            repository: RepairRepositoryImpl(storageService: LocalStorageService()),
            imageService: ImageStorageService(),
            cacheManager: CatalogCacheManager()
        )
    )
}
