//
//  SongRowView.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI

/// Vista que representa una fila individual en la lista de canciones
/// Muestra el título de la canción, su categoría (si está disponible) y un botón para marcar como favorita
struct SongRowView: View {
    /// Canción que se está mostrando en esta fila
    let song: Song
    
    /// Acción a ejecutar cuando el usuario toca el botón de favorito
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Mostrar categoría si está disponible
                if let category = song.category, !category.isEmpty {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            Spacer()
            
            Button(action: onFavoriteToggle) {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(song.isFavorite ? .red : .gray)
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 16) {
        SongRowView(
            song: Song(title: "A Dios sea la gloria", lyrics: "Como dijo el profeta, honra y gloria...", category: "Alabanza"),
            onFavoriteToggle: {}
        )
        
        SongRowView(
            song: Song(title: "Elección de Dios", lyrics: "Textos de la canción...", category: "Elección"),
            onFavoriteToggle: {}
        )
        
        SongRowView(
            song: Song(title: "Sin categoría", lyrics: "Texto..."),
            onFavoriteToggle: {}
        )
    }
    .padding()
}

