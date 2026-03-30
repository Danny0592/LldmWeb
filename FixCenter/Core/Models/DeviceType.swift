//
//  DeviceType.swift
//  FixCenter
//
//  Created by daniel ortiz millan on 05/12/25.
//

import Foundation
import SwiftUI

/// Define los tipos de dispositivos que la aplicación puede gestionar.
enum DeviceType: String, Codable, CaseIterable, Identifiable {
    /// Dispositivos móviles inteligentes.
    case phone = "Celular"
    /// Computadoras portátiles.
    case laptop = "Laptop"
    /// Computadoras de escritorio.
    case desktop = "PC"
    /// Tablets y dispositivos similares.
    case tablet = "Tablet"
    /// Consolas de videojuegos.
    case console = "Consola"
    /// Monitores de PC.
    case monitor = "Monitor"
    /// Televisiones.
    case tv = "Televisión"
    /// Cualquier otro tipo de dispositivo no listado.
    case other = "Otro"
    
    /// Identificador único para conformidad con el protocolo Identifiable.
    var id: String { rawValue }
    
    /// Nombre del icono de SF Symbols asociado al tipo de dispositivo.
    var icon: String {
        switch self {
        case .phone:
            return "iphone"
        case .laptop:
            return "laptopcomputer"
        case .desktop:
            return "desktopcomputer"
        case .tablet:
            return "ipad"
        case .console:
            return "gamecontroller"
        case .monitor:
            return "display"
        case .tv:
            return "tv"
        case .other:
            return "ellipsis.circle"
        }
    }
    
    /// Color temático asociado al tipo de dispositivo para la interfaz.
    var color: Color {
        switch self {
        case .phone:
            return .blue
        case .laptop:
            return .purple
        case .desktop:
            return .indigo
        case .tablet:
            return .cyan
        case .console:
            return .orange
        case .monitor:
            return .teal
        case .tv:
            return .pink
        case .other:
            return .gray
        }
    }
    
    /// Identificador utilizado en Firestore para la colección 'categories'.
    var catalogId: String {
        switch self {
        case .phone:
            return "celular"
        case .laptop:
            return "laptop"
        case .desktop:
            return "pc"
        case .tablet:
            return "tablet"
        case .console:
            return "consola"
        case .monitor:
            return "monitor"
        case .tv:
            return "tv"
        case .other:
            return "other"
        }
    }
}


