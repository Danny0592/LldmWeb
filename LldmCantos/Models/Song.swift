//
//  Song.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import Foundation

/// Modelo de datos que representa una canción
/// Contiene toda la información relacionada con una canción: título, letras, estado de favorito,
/// fecha de última visualización, información de PDF (local o remoto) y categoría temática
struct Song: Identifiable, Codable, Equatable {
    /// Identificador único de la canción
    let id: UUID
    
    /// Título de la canción
    var title: String
    
    /// Letra completa de la canción (puede ser editada por el usuario)
    var lyrics: String
    
    /// Indica si la canción está marcada como favorita por el usuario
    var isFavorite: Bool
    
    /// Fecha y hora de la última vez que el usuario visualizó esta canción
    var lastViewed: Date?
    
    /// Nombre del archivo PDF si está incluido en el bundle de la app (PDFs locales)
    var pdfFileName: String?
    
    /// URL completa del PDF si está almacenado en el servidor remoto
    var pdfURL: String?
    
    /// Categoría o tema de la canción (Ej: Elección, Llamamiento, Alabanza, etc.)
    var category: String?
    
    /// Inicializador para crear una nueva canción
    /// - Parameters:
    ///   - id: Identificador único (se genera automáticamente si no se proporciona)
    ///   - title: Título de la canción
    ///   - lyrics: Letra de la canción
    ///   - isFavorite: Si la canción es favorita (por defecto false)
    ///   - lastViewed: Fecha de última visualización (por defecto nil)
    ///   - pdfFileName: Nombre del archivo PDF local (por defecto nil)
    ///   - pdfURL: URL del PDF remoto (por defecto nil)
    ///   - category: Categoría temática de la canción (por defecto nil)
    init(id: UUID = UUID(), title: String, lyrics: String, isFavorite: Bool = false, lastViewed: Date? = nil, pdfFileName: String? = nil, pdfURL: String? = nil, category: String? = nil) {
        self.id = id
        self.title = title
        self.lyrics = lyrics
        self.isFavorite = isFavorite
        self.lastViewed = lastViewed
        self.pdfFileName = pdfFileName
        self.pdfURL = pdfURL
        self.category = category
    }
    
    /// Determina la fuente del PDF (local o remoto) basándose en qué propiedad está disponible
    /// Prioriza PDFs remotos sobre PDFs locales
    /// - Returns: PDFSource si hay un PDF disponible, nil en caso contrario
    var pdfSource: PDFSource? {
        if let url = pdfURL {
            return .remote(url)
        } else if let fileName = pdfFileName {
            return .local(fileName)
        }
        return nil
    }
    
    /// Obtiene la primera letra del título en mayúscula para organización alfabética
    var firstLetter: String {
        String(title.prefix(1)).uppercased()
    }
}

/// Enum que representa la fuente de un archivo PDF
/// Puede ser local (desde el bundle de la app) o remoto (desde un servidor)
enum PDFSource {
    /// PDF almacenado localmente en el bundle de la app
    /// - Parameter fileName: Nombre del archivo PDF sin extensión
    case local(String)
    
    /// PDF almacenado en un servidor remoto
    /// - Parameter urlString: URL completa del PDF
    case remote(String)
}

