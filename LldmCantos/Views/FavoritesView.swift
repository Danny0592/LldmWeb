//
//  FavoritesView.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: SongViewModel
    @State private var selectedSong: Song?
    @State private var selectedPDFSource: PDFSourceWrapper?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo de la app (azul oscuro para contraste con logo blanco)
                Color(red: 0.07, green: 0.07, blue: 0.27)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                HStack {
                    // Logo
                    Image("logo lldm")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .padding(.trailing, 8)
                    
//                    Text("Favoritos")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Profile picture placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if favoriteSections.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "list.star")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No tienes cantos favoritos")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    // Favorites list
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(sortedSections, id: \.0) { section, songs in
                                Section {
                                    ForEach(songs) { song in
                                        Button(action: {
                                            viewModel.markAsViewed(song)
                                            
                                            // Obtener nombre del archivo
                                            let fileName: String
                                            if let pdfFileName = song.pdfFileName {
                                                fileName = pdfFileName
                                            } else if let pdfURL = song.pdfURL {
                                                // Extraer nombre del archivo de la URL
                                                fileName = pdfURL.components(separatedBy: "/").last ?? pdfURL
                                            } else {
                                                fileName = "Sin archivo"
                                            }
                                            
                                            // Obtener URL completa
                                            let fileURL: String
                                            if let pdfURL = song.pdfURL {
                                                fileURL = pdfURL
                                            } else if let pdfFileName = song.pdfFileName {
                                                fileURL = "Local: \(pdfFileName)"
                                            } else {
                                                fileURL = "Sin URL"
                                            }
                                            
                                            // Print con la información solicitada
                                            print("📄 Canción seleccionada:")
                                            print("   Nombre: \(song.title)")
                                            print("   Categoría: \(song.category ?? "Sin categoría")")
                                            print("   Archivo: \(fileName)")
                                            print("   URL: \(fileURL)")
                                            
                                            // Si tiene PDF (local o remoto), abrir directamente el PDF
                                            if let pdfSource = song.pdfSource {
                                                selectedPDFSource = PDFSourceWrapper(id: UUID().uuidString, source: pdfSource, songTitle: song.title)
                                            } else {
                                                // Si no tiene PDF, mostrar la vista de detalle normal
                                                selectedSong = song
                                            }
                                        }) {
                                            SongRowView(song: song) {
                                                viewModel.toggleFavorite(for: song)
                                            }
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Divider()
                                            .background(.white.opacity(0.3))
                                            .padding(.leading)
                                    }
                                } header: {
                                    Text(section)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(red: 0.07, green: 0.07, blue: 0.27))
                                }
                            }
                        }
                    }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedSong) { song in
                SongDetailView(song: song, viewModel: viewModel)
                    .interactiveDismissDisabled()
            }
            .sheet(item: $selectedPDFSource) { wrapper in
                PDFViewer(source: wrapper.source, songTitle: wrapper.songTitle)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    private var favoriteSections: [(String, [Song])] {
        viewModel.favoriteSongsByAlphabet.sorted { $0.key < $1.key }
    }
    
    private var sortedSections: [(String, [Song])] {
        favoriteSections
    }
}

#Preview {
    FavoritesView(viewModel: SongViewModel())
}

