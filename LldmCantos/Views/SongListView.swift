//
//  SongListView.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI

/// Vista principal que muestra la lista completa de canciones
/// Incluye: header con logo, barra de búsqueda, carrusel de categorías, y lista de canciones organizada alfabéticamente
struct SongListView: View {
    /// ViewModel que gestiona el estado y la lógica de las canciones
    @ObservedObject var viewModel: SongViewModel
    
    /// Canción seleccionada para mostrar en la vista de detalle (si no tiene PDF)
    @State private var selectedSong: Song?
    
    /// Fuente PDF seleccionada para mostrar en el visor de PDFs
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
                    
//                    Text("")
//                        .font(.system(size: 26, design: .serif))
//                        .italic()
//                        .foregroundColor(.white)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [.blue, .red, .purple],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
                    
                   
                    Spacer()
                    
                    // Botón de sincronización
                    Button(action: {
                        viewModel.syncWithServer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                            .font(.title3)
                    }
                    .disabled(viewModel.isSyncing)
                    
//                    // Profile picture placeholder
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 40, height: 40)
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.gray)
//                        )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(red: 18, green: 19, blue: 138).opacity(0))
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField(
                        text: $viewModel.searchText,
                        prompt: Text("Buscar por nombre...").foregroundColor(.white.opacity(0.7)) // Aquí controlas el color
                    ) {
                        Text("Etiqueta") // Esto es para accesibilidad
                    }
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white) // Color del texto que se escribe
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Carrusel de categorías (debajo del buscador)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Botón "Todas" para mostrar todas las canciones
                        CategoryButton(
                            title: "Todas",
                            isSelected: viewModel.selectedCategory == nil,
                            count: viewModel.songs.count
                        ) {
                            viewModel.selectCategory(nil)
                        }
                        
                        // Botones para cada categoría
                        ForEach(viewModel.allCategories, id: \.self) { category in
                            let count = viewModel.songs.filter { $0.category == category }.count
                            CategoryButton(
                                title: category,
                                isSelected: viewModel.selectedCategory == category,
                                count: count
                            ) {
                                viewModel.selectCategory(category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Loading indicator
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        Text("Cargando canciones...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Spacer()
                } else if let error = viewModel.errorMessage, viewModel.songs.isEmpty {
                    // Solo mostrar error si no hay canciones en la base de datos
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Reintentar") {
                            viewModel.errorMessage = nil
                            viewModel.isLoading = false
                            viewModel.isSyncing = false
                            viewModel.syncWithServer()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                        .disabled(viewModel.isSyncing)
                    }
                    Spacer()
                } else {
                    // Song list
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
    
    private var sortedSections: [(String, [Song])] {
        viewModel.songsByAlphabet.sorted { $0.key < $1.key }
    }
}

/// Componente reutilizable para mostrar un botón de categoría en el carrusel
/// Muestra el nombre de la categoría, la cantidad de canciones en esa categoría,
/// y cambia su estilo visual cuando está seleccionada
struct CategoryButton: View {
    /// Nombre de la categoría que se mostrará en el botón
    let title: String
    
    /// Indica si esta categoría está actualmente seleccionada
    let isSelected: Bool
    
    /// Número de canciones que pertenecen a esta categoría
    let count: Int
    
    /// Acción que se ejecuta cuando el usuario toca el botón
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                // Mostrar contador de canciones entre paréntesis
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .opacity(0.7)
                }
            }
            .foregroundColor(isSelected ? .white : Color(red: 0.3, green: 0.7, blue: 0.9))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected 
                    ? Color(red: 0.3, green: 0.7, blue: 0.9)  // Fondo azul claro sólido si está seleccionada
                    : Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.1)  // Fondo translúcido si no está seleccionada
            )
            .cornerRadius(16)
        }
    }
}

#Preview {
    SongListView(viewModel: SongViewModel())
}

