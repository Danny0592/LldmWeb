//
//  PDFViewRepresentable.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI
import PDFKit

struct PDFViewRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Intentar cargar el PDF desde la URL
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        } else if let data = try? Data(contentsOf: url),
                  let document = PDFDocument(data: data) {
            // Si falla cargar directamente desde URL, intentar cargar desde Data
            pdfView.document = document
        }
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Actualizar el documento si la URL cambia
        if pdfView.document == nil {
            if let document = PDFDocument(url: url) {
                pdfView.document = document
            } else if let data = try? Data(contentsOf: url),
                      let document = PDFDocument(data: data) {
                pdfView.document = document
            }
        }
    }
}

struct PDFSourceWrapper: Identifiable {
    let id: String
    let source: PDFSource
    let songTitle: String? // Título de la canción para mostrar en lugar del nombre del archivo
}

struct PDFViewer: View {
    let source: PDFSource
    let songTitle: String? // Título de la canción
    @Environment(\.dismiss) var dismiss
    @State private var pdfURL: URL?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    init(source: PDFSource, songTitle: String? = nil) {
        self.source = source
        self.songTitle = songTitle
    }
    
    var displayTitle: String {
        // Si tenemos el título de la canción, usarlo directamente
        if let songTitle = songTitle {
            return songTitle
        }
        
        // Si no, generar el título desde el nombre del archivo
        switch source {
        case .local(let fileName):
            // Remover extensión y limpiar
            let title = fileName.replacingOccurrences(of: ".pdf", with: "", options: .caseInsensitive)
            return title
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
        case .remote(let urlString):
            // Obtener el nombre del archivo desde la URL
            guard let url = URL(string: urlString),
                  let fileName = url.lastPathComponent.components(separatedBy: ".").first else {
                return "PDF"
            }
            // Limpiar el nombre: reemplazar _ y - con espacios
            return fileName
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo azul oscuro para toda la vista
                Color(red: 0.07, green: 0.07, blue: 0.27)
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                        Text("Cargando PDF...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else if let url = pdfURL {
                    PDFViewRepresentable(url: url)
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Error al cargar PDF")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.27), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .task {
                await loadPDF()
            }
        }
    }
    
    @MainActor
    private func loadPDF() async {
        isLoading = true
        errorMessage = nil
        
        switch source {
        case .local(let fileName):
            // Cargar PDF local del bundle
            if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
                pdfURL = url
                isLoading = false
            } else {
                errorMessage = "No se pudo encontrar el archivo: \(fileName).pdf"
                isLoading = false
            }
            
        case .remote(let urlString):
            // Normalizar la URL (corregir si falta :// o tiene espacios)
            var normalizedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Corregir http// a http://
            normalizedURL = normalizedURL.replacingOccurrences(of: "http//", with: "http://")
            normalizedURL = normalizedURL.replacingOccurrences(of: "https//", with: "https://")
            
            guard let url = URL(string: normalizedURL) else {
                errorMessage = "URL inválida: \(urlString)"
                isLoading = false
                return
            }
            
            // Descargar el PDF primero y luego mostrarlo
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 15.0
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Error: respuesta inválida del servidor"
                    isLoading = false
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    errorMessage = "Error al descargar PDF: código \(httpResponse.statusCode)\nVerifica que el servidor esté corriendo"
                    isLoading = false
                    return
                }
                
                // Verificar que los datos sean un PDF válido
                guard data.count > 0 else {
                    errorMessage = "Error: el PDF está vacío"
                    isLoading = false
                    return
                }
                
                // Guardar temporalmente el PDF descargado
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("pdf")
                
                try data.write(to: tempURL)
                pdfURL = tempURL
                isLoading = false
            } catch let error as URLError {
                var message = "Error al descargar PDF: "
                switch error.code {
                case .notConnectedToInternet:
                    message += "Sin conexión a internet"
                case .cannotConnectToHost:
                    message += "No se puede conectar al servidor.\nVerifica que:\n1. El servidor esté corriendo (node index.js)\n2. Tu iPhone y Mac estén en la misma red Wi-Fi"
                case .timedOut:
                    message += "Tiempo de espera agotado"
                default:
                    message += error.localizedDescription
                }
                errorMessage = message
                isLoading = false
            } catch {
                errorMessage = "Error al descargar PDF: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    PDFViewer(source: .local("ejemplo"), songTitle: "Ejemplo de Canción")
}
