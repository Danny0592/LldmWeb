//
//  DatabaseService.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import Foundation
import SQLite3

class DatabaseService {
    static let shared = DatabaseService()
    
    private var db: OpaquePointer?
    private let dbPath: URL
    
    private init() {
        // Ubicar la base de datos en el directorio de documentos de la app
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dbPath = documentsPath.appendingPathComponent("lldmcantos.db")
        
        // Crear base de datos si no existe
        openDatabase()
        createTable()
    }
    
    private func openDatabase() {
        if sqlite3_open(dbPath.path, &db) != SQLITE_OK {
            print("❌ Error al abrir la base de datos")
        }
    }
    
    private func createTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS songs (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                lyrics TEXT,
                is_favorite INTEGER DEFAULT 0,
                last_viewed REAL,
                pdf_url TEXT,
                pdf_file_name TEXT,
                category TEXT,
                created_at REAL DEFAULT (julianday('now')),
                updated_at REAL DEFAULT (julianday('now'))
            );
            """
        
        // Agregar columna category si no existe (para bases de datos existentes)
        let alterTableSQL = """
            ALTER TABLE songs ADD COLUMN category TEXT;
        """
        
        var alterStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, alterTableSQL, -1, &alterStatement, nil) == SQLITE_OK {
            sqlite3_step(alterStatement)
            // Si falla porque la columna ya existe, está bien
        }
        sqlite3_finalize(alterStatement)
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Tabla de canciones creada")
            } else {
                print("❌ Error al crear la tabla")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // Guardar o actualizar una canción
    func saveSong(_ song: Song) {
        let insertSQL = """
            INSERT OR REPLACE INTO songs (id, title, lyrics, is_favorite, last_viewed, pdf_url, pdf_file_name, category, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, julianday('now'));
            """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let idString = song.id.uuidString
            sqlite3_bind_text(statement, 1, (idString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (song.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (song.lyrics as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, song.isFavorite ? 1 : 0)
            
            if let lastViewed = song.lastViewed {
                sqlite3_bind_double(statement, 5, lastViewed.timeIntervalSince1970)
            } else {
                sqlite3_bind_null(statement, 5)
            }
            
            if let pdfURL = song.pdfURL {
                sqlite3_bind_text(statement, 6, (pdfURL as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 6)
            }
            
            if let pdfFileName = song.pdfFileName {
                sqlite3_bind_text(statement, 7, (pdfFileName as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            
            if let category = song.category {
                sqlite3_bind_text(statement, 8, (category as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 8)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                // Éxito
            } else {
                print("❌ Error al guardar canción: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // Guardar múltiples canciones
    func saveSongs(_ songs: [Song]) {
        for song in songs {
            saveSong(song)
        }
    }
    
    // Cargar todas las canciones
    func loadAllSongs() -> [Song] {
        let querySQL = "SELECT id, title, lyrics, is_favorite, last_viewed, pdf_url, pdf_file_name, category FROM songs ORDER BY title;"
        
        var songs: [Song] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let idString = String(cString: sqlite3_column_text(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let lyrics = String(cString: sqlite3_column_text(statement, 2))
                let isFavorite = sqlite3_column_int(statement, 3) == 1
                
                var lastViewed: Date? = nil
                if sqlite3_column_type(statement, 4) != SQLITE_NULL {
                    let timestamp = sqlite3_column_double(statement, 4)
                    lastViewed = Date(timeIntervalSince1970: timestamp)
                }
                
                var pdfURL: String? = nil
                if sqlite3_column_type(statement, 5) != SQLITE_NULL {
                    pdfURL = String(cString: sqlite3_column_text(statement, 5))
                }
                
                var pdfFileName: String? = nil
                if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                    pdfFileName = String(cString: sqlite3_column_text(statement, 6))
                }
                
                var category: String? = nil
                if sqlite3_column_type(statement, 7) != SQLITE_NULL {
                    category = String(cString: sqlite3_column_text(statement, 7))
                }
                
                if let id = UUID(uuidString: idString) {
                    let song = Song(
                        id: id,
                        title: title,
                        lyrics: lyrics,
                        isFavorite: isFavorite,
                        lastViewed: lastViewed,
                        pdfFileName: pdfFileName,
                        pdfURL: pdfURL,
                        category: category
                    )
                    songs.append(song)
                }
            }
        }
        sqlite3_finalize(statement)
        
        return songs
    }
    
    // Actualizar favorito de una canción
    func updateFavorite(_ song: Song) {
        let updateSQL = "UPDATE songs SET is_favorite = ?, updated_at = julianday('now') WHERE id = ?;"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, song.isFavorite ? 1 : 0)
            sqlite3_bind_text(statement, 2, (song.id.uuidString as NSString).utf8String, -1, nil)
            
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    // Actualizar fecha de última vista
    func updateLastViewed(_ song: Song) {
        let updateSQL = "UPDATE songs SET last_viewed = ?, updated_at = julianday('now') WHERE id = ?;"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            let timestamp = Date().timeIntervalSince1970
            sqlite3_bind_double(statement, 1, timestamp)
            sqlite3_bind_text(statement, 2, (song.id.uuidString as NSString).utf8String, -1, nil)
            
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    deinit {
        sqlite3_close(db)
    }
}

