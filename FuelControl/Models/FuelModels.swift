import SwiftUI

enum FuelType: String, Codable, CaseIterable, Identifiable {
    case regular
    case superFuel
    case diesel

    var id: String { rawValue }

    var label: String {
        switch self {
        case .regular: return "Regular"
        case .superFuel: return "Súper"
        case .diesel: return "Diésel"
        }
    }

    var color: Color {
        switch self {
        case .regular: return Color(hex: "1E8E3E")
        case .superFuel: return Color(hex: "ED1C24")
        case .diesel: return Color(hex: "5F6368")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .regular: return Color(hex: "E8F5E9")
        case .superFuel: return Color(hex: "FDECEA")
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
        case .ok: return "Óptimo"
        case .warning: return "Medio"
        case .critical: return "Crítico"
        }
    }

    var color: Color {
        switch self {
        case .ok: return Color(hex: "1E8E3E")
        case .warning: return Color(hex: "F28C28")
        case .critical: return Color(hex: "ED1C24")
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

enum AlertSeverity: String, Codable {
    case critical
    case warning
    case info

    var color: Color {
        switch self {
        case .critical: return Theme.danger
        case .warning: return Theme.accent
        case .info: return Theme.primary
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
    case cortes
    case pipas

    var relatedFuelType: FuelType {
        switch self {
        case .inventario, .merma: return .regular
        case .pipas: return .diesel
        case .cortes: return .superFuel
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

    var level: TankLevel { TankLevel(percentage: percentage) }
    var isLow: Bool { level == .critical }
}

struct AlertItem: Identifiable {
    let id: String
    let severity: AlertSeverity
    let category: AlertCategory
    let title: String
    let description: String
    let timeAgo: String
    var fuelType: FuelType? = nil
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
        case .revPerGallon: return dailyGallons == 0 ? 0 : (Double(dailySales) / Double(dailyGallons) * 100).rounded() / 100
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
    let superFuel: Int
    let diesel: Int

    var id: String { hour }
    var total: Int { regular + superFuel + diesel }
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
