//
//  SongDetailView.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI

struct SongDetailView: View {
    let song: Song
    @ObservedObject var viewModel: SongViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditingLyrics = false
    @State private var editedLyrics: String = ""
    @State private var selectedPDFSource: PDFSourceWrapper?
    
    private var currentSong: Song {
        viewModel.songs.first(where: { $0.id == song.id }) ?? song
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(currentSong.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Botones de acción
                    HStack(spacing: 12) {
                        // Botón para ver PDF si existe (local o remoto)
                        if let pdfSource = currentSong.pdfSource {
                            Button(action: {
                                selectedPDFSource = PDFSourceWrapper(id: UUID().uuidString, source: pdfSource, songTitle: currentSong.title)
                            }) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                    Text("Ver PDF")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.3, green: 0.7, blue: 0.9))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Botón para editar letras
                        Button(action: {
                            editedLyrics = currentSong.lyrics
                            isEditingLyrics = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Editar Letra")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Mostrar letras (editable o solo lectura)
                    if isEditingLyrics {
                        TextEditor(text: $editedLyrics)
                            .font(.body)
                            .padding(8)
                            .frame(minHeight: 300)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                    } else {
                        Text(currentSong.lyrics.isEmpty ? "No hay letra disponible. Toca 'Editar Letra' para agregarla." : currentSong.lyrics)
                            .font(.body)
                            .foregroundColor(currentSong.lyrics.isEmpty ? .gray : .primary)
                            .padding(.horizontal)
                            .lineSpacing(4)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Canción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditingLyrics {
                        Button("Guardar") {
                            viewModel.updateLyrics(for: currentSong, lyrics: editedLyrics)
                            isEditingLyrics = false
                        }
                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                    } else {
                        Button(action: {
                            viewModel.toggleFavorite(for: currentSong)
                        }) {
                            Image(systemName: currentSong.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(currentSong.isFavorite ? .red : .gray)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditingLyrics {
                        Button("Cancelar") {
                            isEditingLyrics = false
                        }
                    } else {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
            }
            .sheet(item: $selectedPDFSource) { wrapper in
                PDFViewer(source: wrapper.source, songTitle: wrapper.songTitle)
                    .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    SongDetailView(
        song: Song(title: "A Dios sea la gloria", lyrics: "Como dijo el profeta, honra y gloria al Señor de los cielos, que reina con poder. Elevemos nuestras voces en adoración, cantemos con gozo su gran salvación."),
        viewModel: SongViewModel()
    )
}

