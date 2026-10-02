import SwiftUI

enum UserRole {
    case franchise
    case general
}

enum TankLevel: String, CaseIterable {
    case critical = "Crítico", medium = "Medio", optimal = "Óptimo"
    init(percentage: Int) {
        self = percentage <= 20 ? .critical : percentage <= 50 ? .medium : .optimal
    }
    var color: Color {
        switch self {
        case .critical: return Theme.danger
        case .medium: return Theme.accent
        case .optimal: return Theme.ok
        }
    }
}

struct Manager: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let password: String
    let role: String
}

enum CorteTurno: String, CaseIterable, Identifiable {
    case matutino = "Matutino"
    case vespertino = "Vespertino / Nocturno"
    var id: String { rawValue }
}

enum MovementCategory: String, CaseIterable, Identifiable {
    case ventas = "Ventas"
    case compras = "Compras / Recepción de combustible"
    case perdidas = "Pérdidas o Daños"
    var id: String { rawValue }
}

enum LossReason: String, CaseIterable, Identifiable {
    case merma = "Merma", fuga = "Fuga", falla = "Falla técnica", derrame = "Derrame"
    var id: String { rawValue }
}

struct PumpEntry: Identifiable {
    let id: Int
    var fuel: FuelType = .regular
    var sales = ""
    var purchases = ""
    var losses = ""
    var reason: LossReason = .merma
    var registered = false
}

struct Corte: Identifiable {
    let id: UUID
    let day: Date
    let turno: CorteTurno
    var entries: [PumpEntry]
    var closedAt: Date?
}

struct FuelTotal: Identifiable {
    let fuel: FuelType
    var gallons: Double = 0
    var revenue: Double = 0
    var id: FuelType { fuel }
}
