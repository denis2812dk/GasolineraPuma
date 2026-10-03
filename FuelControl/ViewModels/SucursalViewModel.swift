import Foundation
import Observation

@Observable final class SucursalViewModel {
    let id: String
    private(set) var tanks: [Tank]
    let inventoryRec: InventoryReconciliation?
    let receptions: [Reception]
    private(set) var cortes: [Corte] = []
    private(set) var error: String?
    private let now: () -> Date
    var onChange: (() -> Void)?

    init(id: String, tanks: [Tank], inventoryRec: InventoryReconciliation? = nil,
         receptions: [Reception] = [], cortes: [Corte] = [], now: @escaping () -> Date = Date.init) {
        self.id = id
        self.tanks = tanks
        self.inventoryRec = inventoryRec
        self.receptions = receptions
        self.cortes = cortes
        self.now = now
        ensureToday()
    }

    var today: Date { Calendar.current.startOfDay(for: now()) }
    var todayCortes: [Corte] { cortes.filter { $0.day == today } }
    func ensureToday() {
        for turno in CorteTurno.allCases where !cortes.contains(where: { $0.day == today && $0.turno == turno }) {
            cortes.append(Corte(id: UUID(), day: today, turno: turno,
                                entries: (1...6).map { PumpEntry(id: $0) }))
        }
    }
    func corte(_ id: UUID) -> Corte? { cortes.first { $0.id == id } }
    static func amount(_ text: String) -> Double? {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(clean), value.isFinite, value >= 0, value <= 1_000_000 else { return nil }
        return value
    }
    func valid(_ entry: PumpEntry) -> Bool {
        Self.amount(entry.sales) != nil && Self.amount(entry.purchases) != nil && Self.amount(entry.losses) != nil
    }
    func update(_ corteId: UUID, pump: Int, change: (inout PumpEntry) -> Void) {
        guard let c = cortes.firstIndex(where: { $0.id == corteId }), cortes[c].closedAt == nil,
              let p = cortes[c].entries.firstIndex(where: { $0.id == pump }) else { return }
        change(&cortes[c].entries[p])
        cortes[c].entries[p].registered = false
        error = nil
    }
    func register(_ corteId: UUID, pump: Int) {
        guard let c = cortes.firstIndex(where: { $0.id == corteId }), cortes[c].closedAt == nil,
              let p = cortes[c].entries.firstIndex(where: { $0.id == pump }) else { return }
        guard valid(cortes[c].entries[p]) else {
            error = "Completa las tres categorías con galones entre 0 y 1,000,000. Usa 0 si no hubo movimiento."
            return
        }
        cortes[c].entries[p].registered = true
        error = nil
        onChange?()
    }
    func canClose(_ id: UUID) -> Bool {
        guard let corte = corte(id), corte.closedAt == nil else { return false }
        return corte.entries.count == 6 && Set(corte.entries.map(\.id)) == Set(1...6)
            && corte.entries.allSatisfy { $0.registered && valid($0) }
    }
    func close(_ id: UUID) {
        guard canClose(id), let index = cortes.firstIndex(where: { $0.id == id }) else {
            error = "Debes registrar individualmente las seis bombas antes de cerrar."
            return
        }
        cortes[index].closedAt = now()
        error = nil
        onChange?()
    }
    func total(_ id: UUID, category: MovementCategory, fuel: FuelType? = nil) -> Double {
        guard let corte = corte(id) else { return 0 }
        return corte.entries.filter { fuel == nil || $0.fuel == fuel }.reduce(0) { sum, entry in
            let text: String
            switch category {
            case .ventas: text = entry.sales
            case .compras: text = entry.purchases
            case .perdidas: text = entry.losses
            }
            return sum + (Self.amount(text) ?? 0)
        }
    }
    func closedSales(_ fuel: FuelType) -> Double {
        todayCortes.filter { $0.closedAt != nil }.reduce(0) { $0 + total($1.id, category: .ventas, fuel: fuel) }
    }
}

@Observable final class CorteDetailViewModel {
    let sucursal: SucursalViewModel
    let id: UUID
    init(sucursal: SucursalViewModel, id: UUID) { self.sucursal = sucursal; self.id = id }
    var corte: Corte? { sucursal.corte(id) }
    var entries: [PumpEntry] { corte?.entries ?? [] }
    var isClosed: Bool { corte?.closedAt != nil }
    var canClose: Bool { sucursal.canClose(id) }
    var progress: String { "\(entries.filter(\.registered).count) de 6 bombas registradas" }
    var error: String? { sucursal.error }
    func update(_ pump: Int, change: (inout PumpEntry) -> Void) { sucursal.update(id, pump: pump, change: change) }
    func register(_ pump: Int) { sucursal.register(id, pump: pump) }
    func close() { sucursal.close(id) }
    func total(_ category: MovementCategory, fuel: FuelType? = nil) -> String {
        sucursal.total(id, category: category, fuel: fuel).formatted(.number.precision(.fractionLength(2))) + " gal"
    }
}

@Observable final class CortesViewModel {
    let sucursal: SucursalViewModel
    init(sucursal: SucursalViewModel) { self.sucursal = sucursal }
    var cortes: [Corte] { sucursal.todayCortes }
    func refresh() { sucursal.ensureToday() }
}
