//
//  RepairFormViewModel.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import FirebaseFirestore

/// ViewModel que gestiona el flujo de creación y edición de una reparación a través de varios pasos.
/// Controla la navegación entre secciones, la validación de campos y el guardado final.
@MainActor
class RepairFormViewModel: ObservableObject {
    /// Paso actual del formulario (0 a totalSteps-1).
    @Published var currentStep: Int = 0
    /// La reparación que se está creando o editando.
    @Published var repair: Repair = Repair()
    /// Imágenes temporales del estado inicial.
    @Published var initialImages: [UIImage] = []
    /// Imágenes temporales del trabajo finalizado.
    @Published var finalImages: [UIImage] = []
    /// Indica si se está guardando la información.
    @Published var isLoading: Bool = false
    /// Mensaje de error para mostrar en el formulario.
    @Published var errorMessage: String? = nil
    
    // MARK: - Estado del Catálogo de Dispositivos
    @Published var availableBrands: [DeviceBrand] = []
    @Published var availableModels: [DeviceSpecificModel] = []
    @Published var selectedBrandId: String? = nil
    @Published var isCustomBrand: Bool = false
    @Published var isCustomModel: Bool = false
    @Published var isLoadingCatalog: Bool = false

    
    /// Repositorio de datos.
    private let repository: RepairRepository
    /// Servicio de procesamiento de imágenes.
    private let imageService: ImageService
    /// Servicio de catálogo de Firestore.
    private let catalogService: DeviceCatalogService
    
    /// Número total de secciones del formulario.
    let totalSteps = 4
    /// ID original si estamos editando (nil si es una nueva reparación).
    /// ID original si estamos editando (nil si es una nueva reparación).
    private var originalRepairId: String?
    
    /// Propiedad computada que indica si estamos en modo edición o creación.
    var isEditing: Bool {
        originalRepairId != nil
    }
    
    /// Inicializa el ViewModel, opcionalmente con una reparación existente para editar.
    init(repository: RepairRepository, imageService: ImageService, catalogService: DeviceCatalogService = FirebaseDeviceCatalogService(), repair: Repair? = nil) {
        self.repository = repository
        self.imageService = imageService
        self.catalogService = catalogService
        if let repair = repair {
            self.repair = repair
            self.originalRepairId = repair.id
            // Cargar imágenes existentes para la interfaz
            self.initialImages = repair.initialPhotos.compactMap { UIImage(data: $0) }
            self.finalImages = repair.finalPhotos.compactMap { UIImage(data: $0) }
        } else {
            self.originalRepairId = nil
            self.repair.diagnostics = RepairFormViewModel.generateDefaultDiagnostics(for: self.repair.device.type)
        }
    }
    
    /// Indica si se han completado los campos requeridos para avanzar al siguiente paso.
    var canProceedToNextStep: Bool {
        switch currentStep {
        case 0: // Datos del cliente
            return
            !repair.customer.fullName.isEmpty &&
            !repair.customer.phone.isEmpty &&
            !repair.customer.address.isEmpty &&
            !repair.customer.email.isEmpty
        case 1: // Datos del dispositivo
            return
            !repair.device.brand.isEmpty &&
            !repair.device.model.isEmpty &&
            !repair.device.serialNumber.isEmpty &&
            !repair.device.password.isEmpty
        case 2: // Descripción del problema
            return
            !repair.problemDescription.isEmpty
        case 3: // Reparación
            return true
        default:
            return false
        }
    }
    
    /// Avanza al siguiente paso del formulario con animación.
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.spring()) {
                currentStep += 1
            }
        }
    }
    
    /// Retrocede al paso anterior con animación.
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring()) {
                currentStep -= 1
            }
        }
    }
    
    /// Procesa las imágenes y guarda la reparación en el repositorio.
    func saveRepair() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var repairToSave = repair
            
            // Generar folio solo para nuevas reparaciones
            if !isEditing {
                repairToSave.folio = try await generateNextFolio()
            }
            
            // Procesar y comprimir imágenes (iniciales y finales)
            repairToSave.initialPhotos = try await processImages(initialImages)
            repairToSave.finalPhotos = try await processImages(finalImages)
            
            // Normalizar textos (Capitalizar primera letra)
            repairToSave.device.brand = repairToSave.device.brand.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            repairToSave.device.model = repairToSave.device.model.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Persistir cambios
            let totalInitialSize = repairToSave.initialPhotos.reduce(0) { $0 + $1.count }
            let totalFinalSize = repairToSave.finalPhotos.reduce(0) { $0 + $1.count }
            print("📸 [DEBUG] Guardando reparación con \(repairToSave.initialPhotos.count) fotos iniciales (\(totalInitialSize / 1024) KB) y \(repairToSave.finalPhotos.count) fotos finales (\(totalFinalSize / 1024) KB)")
            print("📦 [DEBUG] Tamaño total estimado en blobs: \((totalInitialSize + totalFinalSize) / 1024) KB")
            
            try await repository.saveRepair(repairToSave)
        } catch {
            errorMessage = "Error al guardar reparación: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Genera automáticamente el siguiente folio sincronizado mediante una transacción de Firestore.
    /// Formato solicitado: FC-YYMMDDNN
    private func generateNextFolio() async throws -> String {
        let db = Firestore.firestore()
        let counterRef = db.collection("metadata").document("folios")
        
        // Obtener fecha actual en formato YYMMDD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let currentDateString = dateFormatter.string(from: Date())
        
        return try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let counterDoc: DocumentSnapshot
            do {
                counterDoc = try transaction.getDocument(counterRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var nextNumber = 1
            
            if let data = counterDoc.data() {
                let lastDate = data["lastDate"] as? String ?? ""
                let lastNumber = data["lastNumber"] as? Int ?? 0
                
                // Si seguimos en el mismo día, sumamos 1. Si es día nuevo, reiniciamos a 1.
                if lastDate == currentDateString {
                    nextNumber = lastNumber + 1
                }
            }
            
            // Generar el folio (ej: FC-26040301)
            let folio = String(format: "FC-%@%02d", currentDateString, nextNumber)
            
            // Actualizar el contador central en Firestore
            transaction.setData([
                "lastDate": currentDateString,
                "lastNumber": nextNumber
            ], forDocument: counterRef, merge: true)
            
            return folio
        } as! String
    }

    
    
    /// Genera automáticamente el siguiente folio basado en el año actual (ej. OS-2024-0001).
//    private func generateNextFolio() async throws -> String {
//        let repairs = try await repository.fetchRepairs()
//        let year = Calendar.current.component(.year, from: Date())
//        let prefix = "OS-\(year)-"
//        
//        let numbersInYear = repairs.compactMap { repair -> Int? in
//            guard let folio = repair.folio, folio.hasPrefix(prefix) else { return nil }
//            let suffix = String(folio.dropFirst(prefix.count))
//            return Int(suffix)
//        }
//        
//        let nextNumber = (numbersInYear.max() ?? 0) + 1
//        return "\(prefix)\(String(format: "%04d", nextNumber))"
//    }
    
    /// Comprime un set de imágenes utilizando el servicio de imágenes.
    private func processImages(_ images: [UIImage]) async throws -> [Data] {
        var imageData: [Data] = []
        
        for image in images {
            if let compressed = imageService.compressImage(image, maxSizeKB: 200) {
                imageData.append(compressed)
            }
        }
        
        return imageData
    }
    
    // MARK: - Catálogo de Dispositivos (Firestore)
    
    /// Carga las marcas según la categoría actual.
    func loadBrands() async {
        let categoryId = repair.device.type.catalogId
        isLoadingCatalog = true
        do {
            availableBrands = try await catalogService.fetchBrands(for: categoryId)
            // Si la marca actual no existe en la lista, marcamos como "Otro" (si no está vacía)
            if !availableBrands.contains(where: { $0.name == repair.device.brand }) && !repair.device.brand.isEmpty {
                isCustomBrand = true
            }
        } catch {
            print("Error cargando marcas: \(error.localizedDescription)")
        }
        isLoadingCatalog = false
    }
    
    /// Carga los modelos basándose en la marca seleccionada.
    func loadModels(for brand: DeviceBrand) async {
        repair.device.brand = brand.name
        selectedBrandId = brand.id
        repair.device.model = "" // Limpiar modelo al cambiar marca
        isCustomBrand = false
        isCustomModel = false
        
        let categoryId = repair.device.type.catalogId
        isLoadingCatalog = true
        do {
            availableModels = try await catalogService.fetchModels(for: brand.id, categoryId: categoryId)
        } catch {
            print("Error cargando modelos: \(error.localizedDescription)")
        }
        isLoadingCatalog = false
    }
    
    /// Al seleccionar un modelo del catálogo.
    func selectModel(_ model: DeviceSpecificModel) {
        repair.device.model = model.name
        isCustomModel = false
    }
    
    /// Al cambiar el tipo de dispositivo, recargar marcas y limpiar campos.
    func deviceTypeChanged() async {
        repair.device.brand = ""
        repair.device.model = ""
        selectedBrandId = nil
        isCustomBrand = false
        isCustomModel = false
        availableModels = []
        repair.diagnostics = RepairFormViewModel.generateDefaultDiagnostics(for: repair.device.type)
        await loadBrands()
    }
    
    // MARK: - Generación de Diagnóstico por Defecto
    
    /// Genera una lista de items a verificar según el tipo de dispositivo.
    static func generateDefaultDiagnostics(for type: DeviceType) -> [DiagnosticItem] {
        switch type {
        case .phone, .tablet:
            return [
                DiagnosticItem(name: "Pantalla sin rayones profundos o manchas"),
                DiagnosticItem(name: "No tiene píxeles muertos o zonas oscuras"),
                DiagnosticItem(name: "Marco sin golpes fuertes o deformaciones"),
                DiagnosticItem(name: "Parte trasera sin grietas"),
                DiagnosticItem(name: "Cámara sin rayones visibles"),
                DiagnosticItem(name: "Botones (volumen, encendido) funcionan correctamente"),
                DiagnosticItem(name: "Bandeja SIM abre y cierra bien"),
                DiagnosticItem(name: "El teléfono enciende sin problemas"),
                DiagnosticItem(name: "No se reinicia solo"),
                DiagnosticItem(name: "Funciona fluido (sin lag excesivo)"),
                DiagnosticItem(name: "No se sobrecalienta rápidamente"),
                DiagnosticItem(name: "Carga correctamente"),
                DiagnosticItem(name: "No se descarga demasiado rápido"),
                DiagnosticItem(name: "No se calienta al cargar"),
                DiagnosticItem(name: "Porcentaje de batería estable (no baja de golpe)"),
                DiagnosticItem(name: "Señal móvil funciona (llamadas y datos)"),
                DiagnosticItem(name: "Wi-Fi se conecta sin problemas"),
                DiagnosticItem(name: "Bluetooth funciona"),
                DiagnosticItem(name: "GPS funciona correctamente"),
                DiagnosticItem(name: "Altavoces se escuchan claros"),
                DiagnosticItem(name: "Micrófono funciona (prueba con grabación)"),
                DiagnosticItem(name: "Entrada de audífonos (si tiene) funciona"),
                DiagnosticItem(name: "Cámara trasera enfoca bien"),
                DiagnosticItem(name: "Cámara frontal funciona"),
                DiagnosticItem(name: "Flash funciona"),
                DiagnosticItem(name: "No hay manchas en fotos"),
                DiagnosticItem(name: "Pantalla táctil responde en toda la superficie"),
                DiagnosticItem(name: "Sensor de huella funciona"),
                DiagnosticItem(name: "Reconocimiento facial (si tiene) funciona"),
                DiagnosticItem(name: "Sensor de proximidad (apaga pantalla en llamadas)"),
                DiagnosticItem(name: "Puerto de carga funciona correctamente"),
                DiagnosticItem(name: "No está flojo o dañado"),
                DiagnosticItem(name: "Reconoce cable y carga normal"),
                DiagnosticItem(name: "No tiene cuentas bloqueadas (Google / iCloud)"),
                DiagnosticItem(name: "Está restaurado de fábrica (si es usado)"),
                DiagnosticItem(name: "IMEI válido y no reportado"),
                DiagnosticItem(name: "Sistema operativo funcional")
            ]
        case .laptop, .desktop:
            return [
                DiagnosticItem(name: "Encendido"),
                DiagnosticItem(name: "Pantalla"),
                DiagnosticItem(name: "Teclado"),
                DiagnosticItem(name: "Trackpad / Mouse"),
                DiagnosticItem(name: "Puertos USB / I-O"),
                DiagnosticItem(name: "Wi-Fi"),
                DiagnosticItem(name: "Batería (Laptop)")
            ]
        case .console:
            return [
                DiagnosticItem(name: "Encendido"),
                DiagnosticItem(name: "Lectura de Discos"),
                DiagnosticItem(name: "Puerto HDMI / Video"),
                DiagnosticItem(name: "Puertos de Controles"),
                DiagnosticItem(name: "Ventilación / Ruido"),
                DiagnosticItem(name: "Conexión a Internet")
            ]
        case .monitor, .tv:
            return [
                DiagnosticItem(name: "Encendido"),
                DiagnosticItem(name: "Panel (Líneas/Golpes)"),
                DiagnosticItem(name: "Puertos HDMI"),
                DiagnosticItem(name: "Puertos Auxiliares"),
                DiagnosticItem(name: "Altavoces"),
                DiagnosticItem(name: "Botones Físicos")
            ]
        case .other:
            return [
                DiagnosticItem(name: "Encendido general"),
                DiagnosticItem(name: "Daño físico visible"),
                DiagnosticItem(name: "Cables/Puertos")
            ]
        }
    }
}

