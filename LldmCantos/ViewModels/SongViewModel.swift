//
//  SongViewModel.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import Foundation
import SwiftUI
import Combine

// Helper para timeout en async/await
func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw URLError(.timedOut)
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

/// ViewModel principal que gestiona el estado y la lógica de las canciones
/// Maneja la carga desde la base de datos local, sincronización con el servidor,
/// filtrado por texto y categoría, favoritos, historial y edición de letras.
class SongViewModel: ObservableObject {
    /// Lista completa de canciones cargadas desde la base de datos
    @Published var songs: [Song] = []
    
    /// Texto de búsqueda ingresado por el usuario para filtrar canciones
    @Published var searchText: String = ""
    
    /// Categoría seleccionada para filtrar canciones (nil = mostrar todas)
    @Published var selectedCategory: String?
    
    /// Indica si se están cargando canciones desde la base de datos local
    @Published var isLoading: Bool = false
    
    /// Indica si se está sincronizando con el servidor
    @Published var isSyncing: Bool = false
    
    /// Mensaje de error si ocurre algún problema durante la carga o sincronización
    @Published var errorMessage: String?
    
    /// Fecha de la última sincronización exitosa con el servidor
    @Published var lastSyncDate: Date?
    
    private let pdfService = PDFService.shared
    private let databaseService = DatabaseService.shared
    
    /// Inicializador del ViewModel
    /// Carga las canciones desde la base de datos local primero para mostrar contenido rápidamente,
    /// luego inicia la sincronización con el servidor en segundo plano después de un breve delay
    /// para permitir que iOS procese los permisos de red si es necesario
    init() {
        // Primero cargar desde la base de datos local (rápido)
        loadSongsFromDatabase()
        
        // Luego sincronizar con el servidor en segundo plano
        // Esperar más tiempo para dar oportunidad a que iOS procese permisos
        Task {
            // Esperar a que la vista termine de cargar y el usuario dé permiso si es necesario
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 segundos
            syncWithServer()
        }
    }
    
    /// Carga todas las canciones desde la base de datos local SQLite
    /// Esta operación es rápida y permite mostrar contenido inmediatamente al abrir la app
    func loadSongsFromDatabase() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            let songs = self.databaseService.loadAllSongs()
            
            DispatchQueue.main.async {
                self.songs = songs
                self.isLoading = false
                
                // Si hay canciones en la base de datos, limpiar cualquier error previo
                if !songs.isEmpty {
                    self.errorMessage = nil
                }
            }
        }
    }
    
    /// Sincroniza las canciones con el servidor remoto
    /// Descarga la lista actualizada de canciones, preserva los favoritos y letras editadas localmente,
    /// y actualiza las URLs de PDFs y categorías. Implementa retry automático hasta 3 intentos.
    func syncWithServer() {
        guard !isSyncing else { return }
        
        isSyncing = true
        errorMessage = nil // Limpiar errores previos
        
        Task {
            // Intentar hasta 3 veces con retry automático
            var lastError: Error?
            let maxRetries = 3
            
            var success = false
            
            for attempt in 1...maxRetries {
                do {
                    // Timeout adicional para evitar que se quede colgado
                    let responses = try await withTimeout(seconds: 35) {
                        try await self.pdfService.fetchSongs()
                    }
                    
                    await MainActor.run {
                        // Función helper para normalizar títulos (remover guiones y normalizar)
                        func normalizeTitle(_ title: String) -> String {
                            return title
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: "-", with: " ")
                                .replacingOccurrences(of: "_", with: " ")
                                .replacingOccurrences(of: "  ", with: " ") // Reemplazar espacios dobles con uno solo
                                .lowercased()
                        }
                        
                        // Crear un diccionario de canciones existentes por título normalizado para preservar favoritos y letras
                        var existingSongsMap: [String: Song] = [:]
                        for song in self.songs {
                            let normalizedTitle = normalizeTitle(song.title)
                            existingSongsMap[normalizedTitle] = song
                        }
                        
                        // Convertir las respuestas del servidor a objetos Song
                        var updatedSongs: [Song] = []
                        
                        for response in responses {
                            // Limpiar el título: reemplazar guiones y guiones bajos con espacios
                            let cleanedTitle = response.titulo
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: "-", with: " ")
                                .replacingOccurrences(of: "_", with: " ")
                                .replacingOccurrences(of: "  ", with: " ") // Reemplazar espacios dobles con uno solo
                            
                            let titleLower = normalizeTitle(cleanedTitle)
                            
                            if let existingSong = existingSongsMap[titleLower] {
                                // Si la canción ya existe, mantener favoritos y letras, pero actualizar título, PDF URL y categoría
                                var updatedSong = existingSong
                                updatedSong.title = cleanedTitle // Actualizar título desde el servidor (con espacios en lugar de guiones)
                                updatedSong.pdfURL = response.url
                                // Actualizar categoría si viene del servidor
                                if let categoria = response.categoria {
                                    updatedSong.category = categoria
                                }
                                updatedSongs.append(updatedSong)
                            } else {
                                // Si es una canción nueva, crear con datos del servidor
                                let newSong = Song(
                                    title: cleanedTitle, // Título limpio con espacios
                                    lyrics: "", // El servidor no envía letras
                                    pdfURL: response.url,
                                    category: response.categoria // Agregar categoría si viene del servidor
                                )
                                updatedSongs.append(newSong)
                            }
                        }
                        
                        // Guardar en base de datos
                        self.databaseService.saveSongs(updatedSongs)
                        
                        // Actualizar la lista en memoria
                        self.songs = updatedSongs
                        self.lastSyncDate = Date()
                        self.errorMessage = nil // Limpiar error si tuvo éxito
                    }
                    
                    // Éxito, salir del loop
                    success = true
                    await MainActor.run {
                        self.isSyncing = false
                    }
                    break
                    
                } catch {
                    lastError = error
                    
                    // Si no es el último intento, esperar un poco y reintentar
                    if attempt < maxRetries {
                        // Esperar antes de reintentar (2 segundos por intento)
                        try? await Task.sleep(nanoseconds: UInt64(attempt) * 2_000_000_000)
                        continue
                    }
                    
                    // Si falló después de todos los intentos, mostrar error
                    await MainActor.run {
                        // Solo mostrar error si la base de datos está vacía
                        // Si ya hay canciones, continuar usándolas sin mostrar error
                        if self.songs.isEmpty {
                            // Extraer mensaje de error más amigable
                            var errorMsg = ""
                            if let urlError = error as? URLError {
                                switch urlError.code {
                                case .notConnectedToInternet:
                                    errorMsg = "Sin conexión a internet. Verifica tu Wi-Fi o datos móviles."
                                case .cannotConnectToHost:
                                    errorMsg = "No se puede conectar al servidor. El servidor puede estar despertando (puede tardar ~30 segundos). Intenta de nuevo."
                                case .timedOut:
                                    errorMsg = "Tiempo de espera agotado. El servidor puede estar despertando. Intenta de nuevo."
                                default:
                                    errorMsg = "Error de conexión. Verifica tu conexión a internet e intenta de nuevo."
                                }
                            } else if let nsError = error as NSError? {
                                if nsError.domain == "PDFService" {
                                    errorMsg = nsError.localizedDescription
                                } else {
                                    errorMsg = "Error al sincronizar: \(error.localizedDescription)"
                                }
                            } else {
                                errorMsg = "Error al conectar con el servidor. Intenta de nuevo."
                            }
                            self.errorMessage = errorMsg
                        } else {
                            // Si hay canciones en la BD, limpiar error y continuar con las canciones locales
                            self.errorMessage = nil
                        }
                        self.isSyncing = false
                    }
                }
            }
        }
    }
    
    /// Obtiene todas las categorías únicas disponibles en las canciones
    /// Retorna un array ordenado alfabéticamente con todas las categorías
    var allCategories: [String] {
        let categories = Set(songs.compactMap { $0.category }.filter { !$0.isEmpty })
        return Array(categories).sorted()
    }
    
    /// Filtra las canciones según el texto de búsqueda y la categoría seleccionada
    /// - Si no hay texto ni categoría seleccionada: retorna todas las canciones
    /// - Si hay texto de búsqueda: filtra por título o letra
    /// - Si hay categoría seleccionada: filtra por categoría
    /// - Puede combinar ambos filtros si están presentes
    var filteredSongs: [Song] {
        var result = songs
        
        // Filtrar por categoría si hay una seleccionada
        if let selectedCategory = selectedCategory {
            result = result.filter { song in
                song.category == selectedCategory
            }
        }
        
        // Filtrar por texto de búsqueda si hay texto ingresado
        if !searchText.isEmpty {
            result = result.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.lyrics.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    /// Selecciona una categoría para filtrar las canciones
    /// - Parameter category: La categoría a seleccionar. Si es nil, muestra todas las canciones
    func selectCategory(_ category: String?) {
        selectedCategory = category
    }
    
    var songsByAlphabet: [String: [Song]] {
        Dictionary(grouping: filteredSongs.sorted { $0.title < $1.title }) { song in
            song.firstLetter
        }
    }
    
    var favoriteSongs: [Song] {
        songs.filter { $0.isFavorite }
    }
    
    var favoriteSongsByAlphabet: [String: [Song]] {
        Dictionary(grouping: favoriteSongs.sorted { $0.title < $1.title }) { song in
            song.firstLetter
        }
    }
    
    var historySongs: [Song] {
        songs.filter { $0.lastViewed != nil }
            .sorted { ($0.lastViewed ?? Date.distantPast) > ($1.lastViewed ?? Date.distantPast) }
    }
    
    func toggleFavorite(for song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].isFavorite.toggle()
            
            // Guardar en base de datos
            databaseService.updateFavorite(songs[index])
        }
    }
    
    func markAsViewed(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].lastViewed = Date()
            
            // Guardar en base de datos
            databaseService.updateLastViewed(songs[index])
        }
    }
    
    // Actualizar letras de una canción
    func updateLyrics(for song: Song, lyrics: String) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].lyrics = lyrics
            
            // Guardar en base de datos
            databaseService.saveSong(songs[index])
        }
    }
}

