//
//  MainTabView.swift
//  LldmCantos
//
//  Created by daniel ortiz millan on 16/01/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = SongViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SongListView(viewModel: viewModel)
                .tabItem {
                    Label("Cantos", systemImage: "music.note.list")
                }
                .tag(0)
            
            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favoritos", systemImage: "list.star")
                }
                .tag(1)
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("Historial", systemImage: "clock")
                }
                .tag(2)
        }
        .accentColor(Color(red: 0.3, green: 0.7, blue: 0.9))
        .overlay(alignment: .bottomTrailing) {
            // Botón de sincronización flotante
            if viewModel.isSyncing {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Sincronizando...")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.3, green: 0.7, blue: 0.9))
                .cornerRadius(20)
                .padding(.trailing, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    MainTabView()
}

