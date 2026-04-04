//
//  ImageStorageService.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation
import UIKit
import SwiftUI

/// Implementación encargada de gestionar el almacenamiento físico de imágenes.
/// Guarda las fotos en un directorio dedicado dentro de la carpeta Documents.
class ImageStorageService: ImageService {
    /// Ruta del directorio donde se guardan las imágenes de reparación.
    private let imagesDirectory: URL
    
    /// Inicializa el servicio y asegura que el directorio de imágenes exista.
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsPath.appendingPathComponent("RepairImages", isDirectory: true)
        
        // Crear directorio si no existe
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
    
    /// Comprime la imagen de forma iterativa hasta alcanzar el tamaño máximo solicitado (200KB por defecto).
    func compressImage(_ image: UIImage, maxSizeKB: Int = 200) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxSizeKB * 1024 && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    /// Escribe los datos de la imagen en el disco.
    func saveImage(_ data: Data, filename: String) throws -> URL {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
    
    /// Intenta cargar una imagen desde una URL específica.
    func loadImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    /// Elimina físicamente el archivo de imagen de la URL proporcionada.
    func deleteImage(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}


