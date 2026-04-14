//
//  RepairListView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI

/// Vista principal que muestra la lista de reparaciones con funciones de búsqueda y filtrado.
struct RepairListView: View {
    /// ViewModel que gestiona los datos y lógica de la lista.
    @StateObject private var viewModel: RepairListViewModel
    /// Controla la presentación del formulario para crear una nueva reparación.
    @State private var showNewRepair = false
    /// Referencia a la reparación seleccionada para mostrar su detalle.
    @State private var selectedRepair: Repair? = nil
    /// Estado de foco para el campo de búsqueda.
    @FocusState private var isSearchFocused: Bool
    
    /// Gestor de caché del catálogo inyectado desde el App.
    @EnvironmentObject private var cacheManager: CatalogCacheManager
    
    /// Acción para cerrar sesión.
    var onLogout: () -> Void
    
    /// Inicializa la vista con su ViewModel.
    init(viewModel: RepairListViewModel, onLogout: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLogout = onLogout
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                // Header con búsqueda y filtros (fijos arriba)
                VStack(spacing: 16) {
                    searchSection
                    filterSection
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Lista de reparaciones
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredRepairs.isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredRepairs) { repair in
                            RepairCard(repair: repair) {
                                selectedRepair = repair
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteRepair(repair)
                                    }
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadRepairs()
                    }
                }
                }
                
                // Botón flotante para cerrar sesión
                Button(action: {
                    onLogout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 5)
                }
                .padding()
                .padding(.bottom, 16)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("FixCenter")
//            .navigationBarTitleDisplayMode(.large)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewRepair = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showNewRepair) {
                NavigationStack {
                    RepairFormView(
                        viewModel: RepairFormViewModel(
                            repository: viewModel.repository,
                            imageService: ImageStorageService(),
                            cacheManager: cacheManager
                        )
                    )
                }
                .onDisappear {
                    // Recargar la lista cuando se cierra el formulario
                    Task {
                        await viewModel.loadRepairs()
                    }
                }
            }
            .sheet(item: $selectedRepair) { repair in
                NavigationStack {
                    RepairDetailView(
                        viewModel: RepairDetailViewModel(
                            repair: repair,
                            repository: viewModel.repository
                        )
                    )
                }
                .onDisappear {
                    // Recargar la lista cuando se cierra el detalle (por si se actualizó el estado)
                    Task {
                        await viewModel.loadRepairs()
                    }
                }
            }
            .task {
                await viewModel.loadRepairs()
            }
        }
    }
/// Filtrar reparacion
    /// Sección superior que contiene la barra de búsqueda interactiva.
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar reparaciones...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isSearchFocused)
                .onChange(of: viewModel.searchText) { _ in
                    Task {
                        await viewModel.searchRepairs()
                    }
                }
            
            if !viewModel.searchText.isEmpty && isSearchFocused {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    /// Seccion de Status
    /// Barra horizontal de filtros por estado de reparación.
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Todos",
                    isSelected: viewModel.selectedStatus == nil
                ) {
                    viewModel.filterByStatus(nil)
                }
                
                ForEach(RepairStatus.allCases) { status in
                    FilterChip(
                        title: status.rawValue,
                        isSelected: viewModel.selectedStatus == status,
                        color: status.color
                    ) {
                        viewModel.filterByStatus(status)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    /// Vista cuando no hay reparaciones en cualquier seccion
    /// Si no hay reparaciones en la seccion muestra un texto personalizado, dependiendo el status
    private var emptyStateView: some View {
        let title: String
        let message: String
        let icon: String
        
        if let status = viewModel.selectedStatus {
            icon = status.icon
            let statusText: String
            switch status {
            case .diagnosing, .repairing:
                statusText = status.rawValue.lowercased()
            default:
                statusText = "\(status.rawValue.lowercased())s"
            }
            title = "No hay servicios \(statusText)"
            message = "Actualmente no tienes ninguna reparación en este estado"
        } else if !viewModel.searchText.isEmpty {
            icon = "magnifyingglass"
            title = "Sin resultados"
            message = "No encontramos reparaciones que coincidan con \"\(viewModel.searchText)\""
        } else {
            icon = "wrench.and.screwdriver"
            title = "No hay reparaciones"
            message = "Toca el botón + para agregar una nueva reparación"
        }
        
        return VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 100)
    }
}

/// Un chip interactivo utilizado en la barra de filtros.
struct FilterChip: View {
    /// Texto a mostrar en el chip.
    let title: String
    /// Indica si el chip está seleccionado.
    let isSelected: Bool
    /// Color predominante del chip.
    var color: Color = .blue
    /// Acción al pulsar el chip.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RepairListView(
        viewModel: RepairListViewModel(
            repository: RepairRepositoryImpl(
                storageService: LocalStorageService()
            )
        )
    )
}

