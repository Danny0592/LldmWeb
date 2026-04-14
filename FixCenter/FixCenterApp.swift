//
//  FixCenterApp.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
// prueba

import SwiftUI
import FirebaseCore

/// Punto de entrada principal de la aplicación FixCenter.
/// Configura la inyección de dependencias inicial y gestiona el flujo de autenticación.
@main
struct FixCenterApp: App {
    
    /// Servicio compartido para el almacenamiento de datos persistentes.
    private let storageService: StorageService
    /// Servicio compartido para la gestión y procesamiento de imágenes.
    private let imageService: ImageService
    /// Servicio de catálogo para descargar marcas y modelos.
    private let catalogService: DeviceCatalogService
    /// Gestor de caché para el catálogo.
    @StateObject private var cacheManager: CatalogCacheManager

    init() {
        FirebaseApp.configure()
        self.storageService = FirestoreStorageService()
        self.imageService = ImageStorageService()
        self.catalogService = FirebaseDeviceCatalogService()
        _cacheManager = StateObject(wrappedValue: CatalogCacheManager())
        // Descomenta la siguiente línea para subir los datos iniciales a Firestore:
//         DatabaseSeeds.uploadServiceData()
    }
    
    /// Repositorio computado que provee acceso a las reparaciones.
    private var repairRepository: RepairRepository {
        RepairRepositoryImpl(storageService: storageService)
    }
    
    /// Estado que controla si el usuario ha iniciado sesión.
    @State private var isAuthenticated = true
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                RepairListView(
                    viewModel: RepairListViewModel(
                        repository: repairRepository
                    ),
                    onLogout: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isAuthenticated = false
                        }
                    }
                )
                .environmentObject(cacheManager)
                .task {
                    // Sincronización del catálogo al arranque
                    do {
                        print("🔄 [SYNC] Iniciando sincronización del catálogo...")
                        let (brands, models) = try await catalogService.fetchAllCatalog()
                        cacheManager.updateCache(brands: brands, models: models)
                        print("✅ [SYNC] Catálogo sincronizado: \(brands.count) marcas, \(models.count) modelos.")
                    } catch {
                        print("❌ [SYNC] Error sincronizando catálogo: \(error.localizedDescription)")
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                LoginView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isAuthenticated = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }
}
