import SwiftUI

/// Hoja modal para seleccionar una marca de dispositivo.
struct BrandSelectionSheet: View {
    let brands: [DeviceBrand]
    let onSelect: (DeviceBrand) -> Void
    let onSelectOther: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredBrands: [DeviceBrand] {
        if searchText.isEmpty {
            return brands
        } else {
            return brands.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBrands) { brand in
                    Button(action: {
                        onSelect(brand)
                        dismiss()
                    }) {
                        Text(brand.name)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {
                    onSelectOther()
                    dismiss()
                }) {
                    Text("Otro (Escribir manualmente)")
                        .foregroundColor(.blue)
                        .italic()
                }
            }
            .searchable(text: $searchText, prompt: "Buscar marca")
            .navigationTitle("Seleccionar Marca")
            .navigationBarItems(trailing: Button("Cancelar") {
                dismiss()
            })
        }
    }
}

/// Hoja modal para seleccionar un modelo de dispositivo.
struct ModelSelectionSheet: View {
    let models: [DeviceSpecificModel]
    let onSelect: (DeviceSpecificModel) -> Void
    let onSelectOther: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredModels: [DeviceSpecificModel] {
        if searchText.isEmpty {
            return models
        } else {
            return models.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if models.isEmpty {
                    Text("No hay modelos registrados para esta marca.")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredModels) { model in
                        Button(action: {
                            onSelect(model)
                            dismiss()
                        }) {
                            Text(model.name)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Button(action: {
                    onSelectOther()
                    dismiss()
                }) {
                    Text("Otro (Escribir manualmente)")
                        .foregroundColor(.blue)
                        .italic()
                }
            }
            .searchable(text: $searchText, prompt: "Buscar modelo")
            .navigationTitle("Seleccionar Modelo")
            .navigationBarItems(trailing: Button("Cancelar") {
                dismiss()
            })
        }
    }
}
