//
//  RegisterViewModel.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 04/04/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel del formulario de registro (nombre o negocio, correo y contraseña).
@MainActor
class RegisterViewModel: ObservableObject {
    @Published var fullNameOrBusiness = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var onRegisterSuccess: (() -> Void)?

    func register() {
        let name = fullNameOrBusiness.trimmingCharacters(in: .whitespacesAndNewlines)
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !mail.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, completa todos los campos"
            return
        }

        guard mail.contains("@"), mail.contains(".") else {
            errorMessage = "Ingresa un correo electrónico válido"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return
        }

        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.onRegisterSuccess?()
        }
    }
}
