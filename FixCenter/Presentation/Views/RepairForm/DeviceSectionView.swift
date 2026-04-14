//
//  DeviceSectionView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Sección del formulario que recolecta las especificaciones del dispositivo.
struct DeviceSectionView: View {
    /// ViewModel compartido del formulario.
    @ObservedObject var viewModel: RepairFormViewModel
    @FocusState private var focusedField: RepairFormField?
    
    @State private var showBrandSheet = false
    @State private var showModelSheet = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    
                    // Selector de tipo de dispositivo
                    GlassCard {
                        DeviceTypeSelector(selectedType: $viewModel.repair.device.type)
                    }
                    
                    // Información del dispositivo
                    GlassCard {
                        VStack(spacing: 20) {
                            // Campo Dinámico para MARCA
                            if viewModel.isCustomBrand {
                                FloatingTextField(
                                    title: "Marca (Manual)",
                                    text: $viewModel.repair.device.brand,
                                    placeholder: "Ej: Apple, Samsung, HP",
                                    focusState: $focusedField,
                                    focusValue: .deviceBrand
                                )
                                .id(RepairFormField.deviceBrand)
                            } else {
                                FloatingSelectField(
                                    title: "Marca",
                                    text: viewModel.repair.device.brand,
                                    placeholder: viewModel.isLoadingCatalog ? "Cargando..." : "Seleccionar marca",
                                    action: { showBrandSheet = true },
                                    disabled: viewModel.isLoadingCatalog
                                )
                                .id(RepairFormField.deviceBrand)
                            }
                            
                            // Campo Dinámico para MODELO
                            if viewModel.isCustomModel {
                                FloatingTextField(
                                    title: "Modelo (Manual)",
                                    text: $viewModel.repair.device.model,
                                    placeholder: "Ej: iPhone 14, Galaxy S23",
                                    focusState: $focusedField,
                                    focusValue: .deviceModel
                                )
                                .id(RepairFormField.deviceModel)
                            } else {
                                FloatingSelectField(
                                    title: "Modelo",
                                    text: viewModel.repair.device.model,
                                    placeholder: viewModel.selectedBrandId == nil && !viewModel.isCustomBrand 
                                        ? "Primero selecciona una marca" 
                                        : (viewModel.isLoadingCatalog ? "Cargando..." : "Seleccionar modelo"),
                                    action: { showModelSheet = true },
                                    disabled: viewModel.selectedBrandId == nil || viewModel.isLoadingCatalog
                                )
                                .id(RepairFormField.deviceModel)
                            }
                            
                            FloatingTextField(
                                title: "Número de serie",
                                text: $viewModel.repair.device.serialNumber,
                                placeholder: "Opcional",
                                focusState: $focusedField,
                                focusValue: .deviceSerial
                            )
                            .id(RepairFormField.deviceSerial)
                            
                            FloatingTextField(
                                title: "Contraseña o código",
                                text: $viewModel.repair.device.password,
                                placeholder: "Para pruebas después de reparación",
                                keyboardType: .namePhonePad,
                                focusState: $focusedField,
                                focusValue: .devicePassword
                            )
                            .id(RepairFormField.devicePassword)
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
            .onChange(of: viewModel.repair.device.type) { _ in
                Task {
                    await viewModel.deviceTypeChanged()
                }
            }
            .task {
                if viewModel.availableBrands.isEmpty && !viewModel.isCustomBrand {
                    await viewModel.loadBrands()
                }
            }
            .sheet(isPresented: $showBrandSheet) {
                BrandSelectionSheet(
                    brands: viewModel.availableBrands,
                    onSelect: { brand in
                        Task { await viewModel.loadModels(for: brand) }
                    },
                    onSelectOther: {
                        viewModel.isCustomBrand = true
                        viewModel.repair.device.brand = ""
                        viewModel.repair.device.model = ""
                        viewModel.isCustomModel = true
                        viewModel.selectedBrandId = nil
                    }
                )
            }
            .sheet(isPresented: $showModelSheet) {
                ModelSelectionSheet(
                    models: viewModel.availableModels,
                    onSelect: { model in
                        viewModel.selectModel(model)
                    },
                    onSelectOther: {
                        viewModel.isCustomModel = true
                        viewModel.repair.device.model = ""
                    }
                )
            }
        }
    }
}

#Preview {
    DeviceSectionView(
        viewModel: RepairFormViewModel(
            repository: RepairRepositoryImpl(storageService: LocalStorageService()),
            imageService: ImageStorageService(),
            cacheManager: CatalogCacheManager()
        )
    )
}
