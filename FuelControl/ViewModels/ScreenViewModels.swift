import SwiftUI
import Observation

@Observable final class InicioViewModel {
    let general: GeneralViewModel
    let sucursal: SucursalViewModel
    init(general: GeneralViewModel, sucursal: SucursalViewModel) { self.general = general; self.sucursal = sucursal }
    var name: String { general.franchise(sucursal.id)?.name ?? "Estación" }
    var zone: String { general.franchise(sucursal.id)?.zone ?? "" }
    var totals: [FuelTotal] { general.fuelTotals(for: sucursal.id) }
    var revenue: String { totals.reduce(0) { $0 + $1.revenue }.formatted(.currency(code: "USD")) }
    var gallons: String { totals.reduce(0) { $0 + $1.gallons }.formatted(.number.precision(.fractionLength(2))) }
    var tanks: [Tank] { sucursal.tanks }
    var closedCount: String { "\(sucursal.todayCortes.filter { $0.closedAt != nil }.count) de 2" }
}

@Observable final class VentasViewModel {
    let general: GeneralViewModel
    let sucursal: SucursalViewModel
    init(general: GeneralViewModel, sucursal: SucursalViewModel) { self.general = general; self.sucursal = sucursal }
    var totals: [FuelTotal] { general.fuelTotals(for: sucursal.id) }
    var cortes: [Corte] { sucursal.todayCortes }
    func gallons(_ corte: Corte) -> String {
        sucursal.total(corte.id, category: .ventas).formatted(.number.precision(.fractionLength(2))) + " gal"
    }
}

@Observable final class TanquesViewModel {
    let sucursal: SucursalViewModel
    init(sucursal: SucursalViewModel) { self.sucursal = sucursal }
    var tanks: [Tank] { sucursal.tanks }
    var inventoryRec: InventoryReconciliation? { sucursal.inventoryRec }
    var receptions: [Reception] { sucursal.receptions }
}

@Observable final class AlertsViewModel {
    let general: GeneralViewModel
    let sucursal: SucursalViewModel?
    var filter = "todas"
    let categories = ["todas", "críticas", "inventario", "cortes"]
    init(general: GeneralViewModel, sucursal: SucursalViewModel? = nil) {
        self.general = general; self.sucursal = sucursal
    }
    var alerts: [AlertItem] {
        let stations = sucursal.map { [$0] } ?? general.franchises.compactMap { general.sucursales[$0.id] }
        return stations.flatMap { station -> [AlertItem] in
            let name = general.franchise(station.id)?.name ?? "Estación"
            let inventory = station.tanks.filter { $0.level != .optimal }.map { tank in
                AlertItem(id: tank.id, severity: tank.level == .critical ? .critical : .warning,
                          category: .inventario, title: "\(name): \(tank.fuelType.label) · \(tank.level.rawValue)",
                          description: "Tanque al \(tank.percentage)%. Autonomía: \(tank.autonomyDays) días.", timeAgo: "Lectura local", fuelType: tank.fuelType)
            }
            let pending = station.todayCortes.filter { $0.closedAt == nil }.map { corte in
                AlertItem(id: corte.id.uuidString, severity: .info, category: .cortes,
                          title: "\(name): corte \(corte.turno.rawValue)",
                          description: "Pendiente de registrar las seis bombas y cerrar.", timeAgo: "Hoy")
            }
            return inventory + pending
        }
    }
    var filtered: [AlertItem] {
        alerts.filter { filter == "todas" || (filter == "críticas" ? $0.severity == .critical : $0.category.rawValue == filter) }
    }
}
