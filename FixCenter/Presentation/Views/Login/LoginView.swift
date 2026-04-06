//
//  LoginView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 09/03/26.
//

import SwiftUI

/// Vista principal de autenticación que presenta el formulario de inicio de sesión.
/// Utiliza un diseño de "Glassmorphism" sobre un fondo degradado vibrante.
struct LoginView: View {
    /// Instancia del ViewModel que maneja la lógica de autenticación.
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    /// Callback que se ejecuta cuando el inicio de sesión es exitoso.
    let onLoginSuccess: () -> Void
    
    /// Define los campos enfocables en la vista de inicio de sesión.
    enum LoginFormField: Hashable {
        case username
        case password
    }
    
    /// Estado de foco para los campos del formulario.
    @FocusState private var focusedField: LoginFormField?
    /// Presenta el formulario de registro.
    @State private var showRegisterSheet = false
    
    // Gradiente intenso inspirado en el icono de la app
    private let loginGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.3, blue: 0.8),
            Color(red: 0.0, green: 0.6, blue: 0.9),
            Color(red: 0.0, green: 0.8, blue: 0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // Fondo Vibrante
            loginGradient
                .ignoresSafeArea()
            
            // Decoraciones sutiles (Formas orgánicas)
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .offset(x: -50, y: -50)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: 50, y: 50)
                }
            }
            .ignoresSafeArea()
            
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 40) {
                        // Header: Logo o Icono
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                                
                                Image("icono")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 60)
                            
                            Text("FixCenter")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                            
                            Text("Gestión Profesional de Reparaciones")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Formulario con Glassmorphism
                        GlassCard {
                            VStack(spacing: 24) {
                                Text("Iniciar Sesión")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                VStack(spacing: 20) {
                                    FloatingTextField(
                                        title: "Usuario o Correo",
                                        text: $viewModel.username,
                                        icon: "person.fill",
                                        focusState: $focusedField,
                                        focusValue: .username
                                    )
                                    .id(LoginFormField.username)
                                    
                                    FloatingTextField(
                                        title: "Contraseña",
                                        text: $viewModel.password,
                                        isSecure: true,
                                        icon: "lock.fill",
                                        focusState: $focusedField,
                                        focusValue: .password
                                    )
                                    .id(LoginFormField.password)
                                }
                                
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.top, -8)
                                }
                                
                                GradientButton(
                                    title: "Entrar",
                                    action: {
                                        viewModel.login()
                                    },
                                    gradient: AppColors.primaryGradient,
                                    icon: "arrow.right",
                                    isLoading: viewModel.isLoading
                                )
                                .padding(.top, 8)
                                
                                Button(action: {
                                    // Acción futura: Recuperar contraseña
                                }) {
                                    Text("¿Olvidaste tu contraseña?")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Button {
                                    showRegisterSheet = true
                                } label: {
                                    Text("¿No tienes cuenta? Regístrate")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.blue)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                    .onChange(of: focusedField) { newValue in
                        if let field = newValue {
                            withAnimation(.spring()) {
                                proxy.scrollTo(field, anchor: UnitPoint(x: 0.5, y: 0.8))
                            }
                        }
                    }
                }
            }
            .hideKeyboardOnTap()
        }
        .sheet(isPresented: $showRegisterSheet) {
            RegisterView(onRegisterSuccess: onLoginSuccess)
        }
        .onAppear {
            viewModel.onLoginSuccess = onLoginSuccess
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
