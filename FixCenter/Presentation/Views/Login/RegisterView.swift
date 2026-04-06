//
//  RegisterView.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 04/04/26.
//

import SwiftUI

/// Formulario de alta con nombre o negocio, correo y contraseña.
struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()

    let onRegisterSuccess: () -> Void

    enum RegisterFormField: Hashable {
        case fullNameOrBusiness
        case email
        case password
    }

    @FocusState private var focusedField: RegisterFormField?

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
        NavigationStack {
            ZStack {
                loginGradient
                    .ignoresSafeArea()

                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(spacing: 32) {
                            VStack(spacing: 12) {
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
                                .padding(.top, 8)

                                Text("FixCenter")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

                                Text("Gestión Profesional de Reparaciones")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            VStack(spacing: 24) {
                                Text("Crear cuenta")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                GlassCard {
                                    VStack(spacing: 20) {
                                        FloatingTextField(
                                            title: "Nombre del negocio",
                                            text: $viewModel.fullNameOrBusiness,
                                            icon: "building.2.fill",
                                            focusState: $focusedField,
                                            focusValue: .fullNameOrBusiness
                                        )
                                        .id(RegisterFormField.fullNameOrBusiness)

                                        FloatingTextField(
                                            title: "Correo electrónico",
                                            text: $viewModel.email,
                                            keyboardType: .emailAddress,
                                            icon: "envelope.fill",
                                            focusState: $focusedField,
                                            focusValue: .email
                                        )
                                        .id(RegisterFormField.email)

                                        FloatingTextField(
                                            title: "Contraseña",
                                            text: $viewModel.password,
                                            isSecure: true,
                                            icon: "lock.fill",
                                            focusState: $focusedField,
                                            focusValue: .password
                                        )
                                        .id(RegisterFormField.password)

                                        if let error = viewModel.errorMessage {
                                            Text(error)
                                                .font(.caption)
                                                .foregroundColor(.red)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }

                                        GradientButton(
                                            title: "Registrarse",
                                            action: { viewModel.register() },
                                            gradient: AppColors.primaryGradient,
                                            icon: "person.badge.plus",
                                            isLoading: viewModel.isLoading
                                        )
                                        .padding(.top, 4)
                                    }
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal)

//                                Button {
//                                    dismiss()
//                                } label: {
//                                    Text("¿Ya tienes cuenta? Inicia sesión")
//                                        .font(.subheadline)
//                                        .foregroundColor(.white.opacity(0.95))
//                                }
//                                .padding(.bottom, 24)
                            }
                        }
                        .padding()
                        .onChange(of: focusedField) { newValue in
                            if let field = newValue {
                                withAnimation(.spring()) {
                                    proxy.scrollTo(field, anchor: UnitPoint(x: 0.5, y: 0.75))
                                }
                            }
                        }
                    }
                }
                .hideKeyboardOnTap()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.onRegisterSuccess = {
                dismiss()
                onRegisterSuccess()
            }
        }
    }
}

#Preview {
    RegisterView(onRegisterSuccess: {})
}
