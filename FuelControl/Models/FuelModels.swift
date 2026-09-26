import SwiftUI

enum FuelType: String, Codable, CaseIterable, Identifiable {
    case regular
    case especial
    case diesel

    var id: String { rawValue }

    var label: String {
        switch self {
        case .regular: return "Regular"
        case .especial: return "Especial"
        case .diesel: return "Diésel"
        }
    }

    var color: Color {
        switch self {
        case .regular: return Color(hex: "1E8E3E")
        case .especial: return Color(hex: "D93025")
        case .diesel: return Color(hex: "5F6368")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .regular: return Color(hex: "E8F5E9")
        case .especial: return Color(hex: "FDECEA")
        case .diesel: return Color(hex: "F1F3F4")
        }
    }
}

enum FranchiseStatus: String, Codable {
    case ok
    case warning
    case critical

    var label: String {
        switch self {
        case .ok: return "Activa"
        case .warning: return "Atención"
        case .critical: return "Crítica"
        }
    }

    var color: Color {
        switch self {
        case .ok: return Color(hex: "1E8E3E")
        case .warning: return Color(hex: "F28C28")
        case .critical: return Color(hex: "D93025")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .ok: return Color(hex: "E8F5E9")
        case .warning: return Color(hex: "FFF3E0")
        case .critical: return Color(hex: "FDECEA")
        }
    }
}

enum ShiftStatus: String, Codable {
    case abierto
    case cerrado
    case pendiente

    var label: String {
        switch self {
        case .abierto: return "Abierto"
        case .cerrado: return "Cerrado"
        case .pendiente: return "Pendiente"
        }
    }

    var color: Color {
        switch self {
        case .abierto: return Color(hex: "1E8E3E")
        case .cerrado: return Color(hex: "5F6368")
        case .pendiente: return Color(hex: "F28C28")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .abierto: return Color(hex: "E8F5E9")
        case .cerrado: return Color(hex: "F1F3F4")
        case .pendiente: return Color(hex: "FFF3E0")
        }
    }
}

enum AlertSeverity: String, Codable {
    case critical
    case warning
    case info

    var color: Color {
        switch self {
        case .critical: return Color(hex: "D93025")
        case .warning: return Color(hex: "F28C28")
        case .info: return Color(hex: "0B3D91")
        }
    }

    var systemImage: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

enum AlertCategory: String, Codable {
    case inventario
    case merma
    case turnos
    case pipas

    /// Fuel chip shown on the alert card, mirroring the original prototype's mapping.
    var relatedFuelType: FuelType {
        switch self {
        case .inventario, .merma: return .regular
        case .pipas: return .diesel
        case .turnos: return .especial
        }
    }
}

enum CompareMetric: String, CaseIterable, Identifiable {
    case gallons
    case revenue
    case merma
    case revPerGallon

    var id: String { rawValue }

    var label: String {
        switch self {
        case .gallons: return "Galones"
        case .revenue: return "Ingresos ($)"
        case .merma: return "Merma (%)"
        case .revPerGallon: return "Ingreso/galón"
        }
    }

    var shortLabel: String {
        switch self {
        case .gallons: return "Galones"
        case .revenue: return "Ingresos"
        case .merma: return "Merma"
        case .revPerGallon: return "$/gal"
        }
    }
}

struct Tank: Identifiable {
    let id: String
    let fuelType: FuelType
    let capacity: Int
    let current: Int
    let temperature: Int
    let waterLevel: Double
    let lastReading: String
    let autonomyDays: Double

    var percentage: Int {
        Int((Double(current) / Double(capacity) * 100).rounded())
    }

    var isLow: Bool { percentage <= 20 }
}

struct HoseReading: Identifiable {
    let hoseId: String
    let fuelType: FuelType
    let initial: Int
    let final: Int
    let gallons: Int

    var id: String { hoseId }
}

struct Shift: Identifiable {
    let id: String
    let number: Int
    let employee: String
    let status: ShiftStatus
    let startTime: String
    let endTime: String?
    let readings: [HoseReading]
    let gallonsSold: Int
    let cashExpected: Int
    let cashDeclared: Int
}

struct AlertItem: Identifiable {
    let id: String
    let severity: AlertSeverity
    let category: AlertCategory
    let title: String
    let description: String
    let timeAgo: String
}

struct PumpFuelSale: Identifiable {
    let type: FuelType
    let gallons: Int
    let amount: Int

    var id: FuelType { type }
}

struct Pump: Identifiable {
    let id: String
    let number: Int
    let fuels: [PumpFuelSale]
    let flagged: String?
}

struct Franchise: Identifiable {
    let id: String
    let name: String
    let zone: String
    let dailySales: Int
    let dailyGallons: Int
    let merma: Double
    let status: FranchiseStatus
    let alertCount: Int
    let growth: Double
    let sparkline: [Int]

    func value(for metric: CompareMetric) -> Double {
        switch metric {
        case .gallons: return Double(dailyGallons)
        case .revenue: return Double(dailySales)
        case .merma: return merma
        case .revPerGallon: return (Double(dailySales) / Double(dailyGallons) * 100).rounded() / 100
        }
    }
}

struct Reception: Identifiable {
    let id: String
    let date: String
    let fuelType: FuelType
    let invoiced: Int
    let received: Int

    var difference: Int { received - invoiced }
    var differencePercent: Double { Double(difference) / Double(invoiced) * 100 }
    var isWithinTolerance: Bool { abs(differencePercent) < 1 }
}

struct InventoryReconciliation {
    let fuelType: FuelType
    let initial: Int
    let receptions: Int
    let sales: Int
    let theoretical: Int
    let physical: Int
    let difference: Int
    let differencePercent: Double
}

struct HourlySales: Identifiable {
    let hour: String
    let regular: Int
    let especial: Int
    let diesel: Int

    var id: String { hour }
    var total: Int { regular + especial + diesel }
}

struct PaymentMethod: Identifiable {
    let name: String
    let value: Int
    let color: Color

    var id: String { name }
}

struct FuelMixSlice: Identifiable {
    let name: String
    let value: Int
    let color: Color

    var id: String { name }
}

struct MonthlyComparisonPoint: Identifiable {
    let day: Int
    let currentMonth: Int
    let previousMonth: Int

    var id: Int { day }
}

struct HeatmapData {
    let days: [String]
    let hours: [String]
    let values: [[Int]]
}

struct MapPosition {
    let x: CGFloat
    let y: CGFloat
}
