//
//  RepairDetailView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import SwiftUI
/// Vista de detalle de reparacion
/// Vista detallada de una reparación que permite consultar toda la información y actualizar su estado.
struct RepairDetailView: View {
    /// ViewModel que gestiona los datos de la reparación y sus imágenes.
    @ObservedObject var viewModel: RepairDetailViewModel
    @Environment(\.dismiss) var dismiss
    /// Controla la visibilidad del selector de estado.
    @State private var showStatusPicker = false
    /// Indica si se está mostrando una imagen en pantalla completa.
    @State private var showImageFullscreen = false
    /// Índice de la imagen seleccionada para ver en pantalla completa.
    @State private var selectedImageIndex = 0
    /// Determina si se muestran las fotos iniciales (true) o las finales (false).
    @State private var isShowingInitial = true
    /// Controla la visibilidad del formulario de edición.
    @State private var showEditView = false
    /// Controla la alerta de confirmación de eliminación.
    @State private var showDeleteConfirmation = false
    /// Controla la apertura de la cámara.
    @State private var showCamera = false
    /// Controla la apertura de la galería de fotos.
    @State private var showPhotoPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header con información principal
                headerSection
                
                // Información del cliente
                customerSection
                
                // Información del dispositivo
                deviceSection
                
                // Estado y timeline
                statusSection
                
                // Descripción del problema
                problemSection
                
                // Precio
                if viewModel.repair.price != nil {
                    priceSection
                }
                
                // Trabajo realizado
                workSection
                
                // Galería de imágenes
                if !viewModel.initialImageUIs.isEmpty || !viewModel.finalImageUIs.isEmpty {
                    imageGallerySection
                }
                
                // Botón de eliminar
                deleteButton
            }
            .padding()
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea()) // fondo completo blaco azulado
        .navigationTitle("Detalle de Reparación")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditView = true
                }) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showStatusPicker) {
            StatusPickerView(
                currentStatus: viewModel.repair.status,
                onSelect: { status in
                    Task {
                        await viewModel.updateStatus(status)
                    }
                }
            )
        }
        .sheet(isPresented: $showEditView) {
            NavigationStack {
                RepairFormView(
                    viewModel: RepairFormViewModel(
                        repository: viewModel.repository,
                        imageService: ImageStorageService(),
                        repair: viewModel.repair
                    )
                )
            }
            .onDisappear {
                // Recargar la reparación cuando se cierra el editor
                Task {
                    if let updatedRepair = try? await viewModel.repository.fetchRepair(id: viewModel.repair.id) {
                        viewModel.repair = updatedRepair
                        viewModel.loadImages()
                    }
                }
            }
        }
        .alert("Eliminar Reparación", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteRepair()
                    dismiss()
                }
            }
        } message: {
            Text("¿Estás seguro de que deseas eliminar esta reparación? Esta acción no se puede deshacer.")
        }
    }
    /// Boton para eliminar el detalle de reparacion
    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Eliminar Reparación")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
            )
        }
        .padding(.horizontal)
    }
    /// MUESTRA LA MARCA, MODELO DEL DISPOSITIVO, NOMBRE DEL CLIENTE Y EL STATUS
    private var headerSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    if let folio = viewModel.repair.folio, !folio.isEmpty {
                        Text(folio)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.15))
                            )
                    }
                    
                    ZStack {
                        Circle()
                            .fill(viewModel.repair.device.type.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: viewModel.repair.device.type.icon)
                            .font(.system(size: 30))
                            .foregroundColor(viewModel.repair.device.type.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.repair.device.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.repair.customer.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                Button(action: {
                    showStatusPicker = true
                }) {
                    HStack {
                        StatusBadge(status: viewModel.repair.status, size: 20)
                        Text(viewModel.repair.status.rawValue)
                            .font(.headline)
                            .foregroundColor(viewModel.repair.status.color)
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    /// Tarjeta de informacion del cliente que muestra el nombre, telefono, email y direccion
    private var customerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Información del Cliente")
                        .font(.headline)
                    Spacer()
                }
                
                InfoRow(icon: "person.fill", title: "Nombre", value: viewModel.repair.customer.fullName)
                InfoRow(icon: "phone.fill", title: "Teléfono", value: viewModel.repair.customer.phone)
                InfoRow(icon: "envelope.fill", title: "Email", value: viewModel.repair.customer.email)
                InfoRow(icon: "mappin.circle.fill", title: "Dirección", value: viewModel.repair.customer.address)
            }
        }
    }
    /// Tarjet que muestra la informacion del dispositivo, tipo, marca, modelo y contraseña
    private var deviceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Información del Dispositivo")
                        .font(.headline)
                    Spacer()
                }
                
                InfoRow(icon: "tag.fill", title: "Tipo", value: viewModel.repair.device.type.rawValue)
                InfoRow(icon: "building.fill", title: "Marca", value: viewModel.repair.device.brand)
                InfoRow(icon: "cube.box.fill", title: "Modelo", value: viewModel.repair.device.model)
                if !viewModel.repair.device.serialNumber.isEmpty {
                    InfoRow(icon: "number", title: "Número de serie", value: viewModel.repair.device.serialNumber)
                }
                InfoRow(icon: "key.fill", title: "Contraseña", value: viewModel.repair.device.password)
            }
        }
    }
    /// Tarjeta que muestra Estado y Fechas
    private var statusSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Estatus y Fechas")
                        .font(.headline)
                    Spacer()
                }
                
                // Botón para cambiar estado - más visible
                Button(action: {
                    showStatusPicker = true
                }) {
                    HStack {
                        StatusBadge(status: viewModel.repair.status, size: 20)
                        Text(viewModel.repair.status.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.repair.status.color.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fecha de recepción")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.repair.receivedDate.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    if let deliveryDate = viewModel.repair.deliveryDate {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Fecha de entrega")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(deliveryDate.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                        }
                    }
                }
                
                if viewModel.repair.daysInRepair > 0 {
                    Divider()
                    HStack {
                        Text("Días en reparación:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(viewModel.repair.daysInRepair)")
                            .font(.headline)
                            .foregroundColor(viewModel.repair.isOverdue ? .red : .blue)
                    }
                }
            }
        }
    }
    /// Tarjeta que muestra la Descripción del Problema
    private var problemSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Descripción del Problema")
                        .font(.headline)
                    Spacer()
                }
                
                Text(viewModel.repair.problemDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    /// Tarjeta que muestra  el Precio
    private var priceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Precio")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text(viewModel.repair.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
    }
    /// Tarjeta que muestra el Trabajo Realizado
    private var workSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Trabajo Realizado")
                        .font(.headline)
                    Spacer()
                }
                
                if !viewModel.repair.assignedTechnician.isEmpty {
                    InfoRow(
                        icon: "person.badge.key.fill",
                        title: "Técnico asignado",
                        value: viewModel.repair.assignedTechnician
                    )
                    Divider()
                }
                
                if !viewModel.repair.workPerformed.isEmpty {
                    Text(viewModel.repair.workPerformed)
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("No se ha registrado trabajo realizado")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                if !viewModel.repair.notes.isEmpty {
                    Divider()
                    Text("Notas:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.repair.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    /// Tarjeta que muestra las imagenes de Daño inicial y Después de reparación
    private var imageGallerySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Tipo de imágenes", selection: $isShowingInitial) {
                Text("Daño inicial").tag(true)
                Text("Después de reparación").tag(false)
            }
            .pickerStyle(.segmented)
            
            let images = isShowingInitial ? viewModel.initialImageUIs : viewModel.finalImageUIs
            
            if images.isEmpty {
                VStack(spacing: 12) {
                    Text("No hay imágenes para este tipo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    addPhotosMenu
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        addPhotosMenu
                        
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            Button(action: {
                                selectedImageIndex = index
                                showImageFullscreen = true
                            }) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showImageFullscreen) {
            ImageFullscreenView(
                images: isShowingInitial ? viewModel.initialImageUIs : viewModel.finalImageUIs,
                currentIndex: selectedImageIndex
            )
        }
        .sheet(isPresented: $showCamera) {
            CameraView(selectedImage: { image in
                if isShowingInitial {
                    viewModel.initialImageUIs.append(image)
                } else {
                    viewModel.finalImageUIs.append(image)
                }
                Task {
                    await viewModel.saveChanges()
                }
            })
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImages: isShowingInitial ? $viewModel.initialImageUIs : $viewModel.finalImageUIs, maxSelection: 10)
                .onDisappear {
                    Task {
                        await viewModel.saveChanges()
                    }
                }
        }
    }
    /// Boton que permite tomar una fotogrfia desde la camara
    private var addPhotosMenu: some View {
        Menu {
            Button(action: {
                showCamera = true
            }) {
                Label("Cámara", systemImage: "camera.fill")
            }
            
            Button(action: {
                showPhotoPicker = true
            }) {
                Label("Galería", systemImage: "photo.on.rectangle")
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Agregar")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.blue)
            .frame(width: 110, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
}

/// Una fila que muestra una etiqueta con icono y su valor correspondiente.
struct InfoRow: View {
    /// Nombre del icono de SF Symbols.
    let icon: String
    /// Título descriptivo del dato.
    let title: String
    /// Valor del dato a mostrar.
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value.isEmpty ? "No especificado" : value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

/// Vista para seleccionar un nuevo estado para la reparación.
struct StatusPickerView: View {
    /// El estado actual de la reparación.
    let currentStatus: RepairStatus
    /// Callback que se ejecuta cuando se selecciona un nuevo estado.
    let onSelect: (RepairStatus) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Información del estado actual
                VStack(spacing: 12) {
                    Text("Estado Actual")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        StatusBadge(status: currentStatus, size: 24)
                        Text(currentStatus.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(currentStatus.color)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(currentStatus.color.opacity(0.1))
                
                // Lista de estados disponibles
                List {
                    Section {
                        ForEach(RepairStatus.allCases) { status in
                            Button(action: {
                                onSelect(status)
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    StatusBadge(status: status, size: 20)
                                    Text(status.rawValue)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if status == currentStatus {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        Text("Selecciona un nuevo estado")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cambiar Estado")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Vista que muestra una galería de imágenes en pantalla completa con soporte para navegación por pestañas.
struct ImageFullscreenView: View {
    /// Array de imágenes a mostrar.
    let images: [UIImage]
    /// Índice inicial.
    let currentIndex: Int
    @Environment(\.dismiss) var dismiss
    /// Índice de la imagen que se muestra actualmente.
    @State private var currentImageIndex: Int
    
    init(images: [UIImage], currentIndex: Int) {
        self.images = images
        self.currentIndex = currentIndex
        _currentImageIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                TabView(selection: $currentImageIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationTitle("\(currentImageIndex + 1) de \(images.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RepairDetailView(
            viewModel: RepairDetailViewModel(
                repair: Repair(
                    customer: Customer(fullName: "Juan Pérez", phone: "1234567890"),
                    device: Device(type: .phone, brand: "Apple", model: "iPhone 14"),
                    problemDescription: "Pantalla rota",
                    status: .repairing
                ),
                repository: RepairRepositoryImpl(
                    storageService: LocalStorageService()
                )
            )
        )
    }
}


