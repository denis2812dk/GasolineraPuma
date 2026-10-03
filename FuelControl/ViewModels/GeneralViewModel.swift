import SwiftUI
import Observation

struct GeneralAccount {
    let name = "Alejandro Rivas"
    let email = "alejandro@fuelcontrol.com"
    let password = "puma2026"
}

@Observable final class GeneralViewModel {
    private var seeds: [Franchise]
    private var fuelSeeds: [String: [FuelTotal]] = [:]
    private(set) var managers: [Manager] = []
    private(set) var assignments: [String: UUID] = [:]
    private(set) var sucursales: [String: SucursalViewModel] = [:]
    private(set) var mapPositions: [String: MapPosition]
    private(set) var prices: [FuelType: Double] = [.regular: 3.75, .superFuel: 4.25, .diesel: 3.50]
    let generalAccount = GeneralAccount()

    init() {
        if let saved = PersistenceStore.load() {
            restore(from: saved)
        } else {
            seedMockData()
        }
    }

    private func seedMockData() {
        seeds = MockData.franchises
        mapPositions = MockData.franchiseMapPositions
        seedDemoManagers()
        fuelSeeds = [:]
        sucursales = [:]
        for franchise in seeds {
            let regular = franchise.dailyGallons * 60 / 100
            let superGallons = franchise.dailyGallons * 25 / 100
            let regularRevenue = franchise.dailySales * 60 / 100
            let superRevenue = franchise.dailySales * 25 / 100
            fuelSeeds[franchise.id] = [
                FuelTotal(fuel: .regular, gallons: Double(regular), revenue: Double(regularRevenue)),
                FuelTotal(fuel: .superFuel, gallons: Double(superGallons), revenue: Double(superRevenue)),
                FuelTotal(fuel: .diesel, gallons: Double(franchise.dailyGallons - regular - superGallons),
                          revenue: Double(franchise.dailySales - regularRevenue - superRevenue))
            ]
            let tanks = franchise.id == "f1" ? MockData.tanks : Self.defaultTanks(id: franchise.id)
            let vm = SucursalViewModel(id: franchise.id, tanks: tanks,
                inventoryRec: franchise.id == "f1" ? MockData.inventoryRec : nil,
                receptions: franchise.id == "f1" ? MockData.receptions : [])
            vm.onChange = { [weak self] in self?.persist() }
            sucursales[franchise.id] = vm
        }
    }

    private func restore(from state: PersistedState) {
        seeds = state.franchises
        fuelSeeds = state.fuelSeeds
        managers = state.managers
        assignments = state.assignments
        mapPositions = state.mapPositions
        prices = state.prices
        sucursales = [:]
        for franchise in seeds {
            let snapshot = state.sucursales[franchise.id]
            let vm = SucursalViewModel(
                id: franchise.id,
                tanks: snapshot?.tanks ?? Self.defaultTanks(id: franchise.id),
                inventoryRec: snapshot?.inventoryRec,
                receptions: snapshot?.receptions ?? [],
                cortes: snapshot?.cortes ?? [])
            vm.onChange = { [weak self] in self?.persist() }
            sucursales[franchise.id] = vm
        }
    }

    /// Persiste el estado actual (sucursales, gerentes, precios, cortes) a disco.
    func persist() {
        var snapshot: [String: SucursalSnapshot] = [:]
        for (id, vm) in sucursales {
            snapshot[id] = SucursalSnapshot(tanks: vm.tanks, cortes: vm.cortes,
                                             inventoryRec: vm.inventoryRec, receptions: vm.receptions)
        }
        PersistenceStore.save(PersistedState(franchises: seeds, fuelSeeds: fuelSeeds, managers: managers,
                                              assignments: assignments, mapPositions: mapPositions,
                                              prices: prices, sucursales: snapshot))
    }

    /// Borra los datos guardados y vuelve a los datos de demostración originales.
    func resetToDemoData() {
        PersistenceStore.clear()
        seedMockData()
    }
    static func defaultTanks(id: String) -> [Tank] {
        FuelType.allCases.map {
            Tank(id: "\(id)-\($0.rawValue)", fuelType: $0, capacity: 10000, current: 6000,
                 temperature: 84, waterLevel: 0, lastReading: "Inicial", autonomyDays: 3)
        }
    }
    private func seedDemoManagers() {
        let maria = Manager(id: UUID(), name: "María López", email: "maria@fuelcontrol.com",
                             password: "turno123", role: "Gerente de sucursal")
        let juan = Manager(id: UUID(), name: "Juan García", email: "juan@fuelcontrol.com",
                            password: "turno123", role: "Gerente de sucursal")
        managers = [maria, juan]
        assignments = ["f1": maria.id, "f2": juan.id]
    }
    func refreshDay() { sucursales.values.forEach { $0.ensureToday() } }
    func fuelTotals(for id: String? = nil) -> [FuelTotal] {
        let ids = id.map { [$0] } ?? seeds.map(\.id)
        return FuelType.allCases.map { fuel in
            var result = FuelTotal(fuel: fuel)
            for id in ids {
                let seed = fuelSeeds[id]?.first { $0.fuel == fuel }
                let sales = sucursales[id]?.closedSales(fuel) ?? 0
                result.gallons += (seed?.gallons ?? 0) + sales
                result.revenue += (seed?.revenue ?? 0) + sales * price(fuel)
            }
            return result
        }
    }
    func price(_ fuel: FuelType) -> Double { prices[fuel] ?? 0 }

    @discardableResult func setPrice(_ value: Double, for fuel: FuelType) -> Bool {
        guard value > 0, value <= 100 else { return false }
        prices[fuel] = (value * 100).rounded() / 100
        persist()
        return true
    }
    var franchises: [Franchise] {
        seeds.map { seed in
            let totals = fuelTotals(for: seed.id)
            return Franchise(id: seed.id, name: seed.name, zone: seed.zone,
                             dailySales: Int(totals.reduce(0) { $0 + $1.revenue }.rounded()),
                             dailyGallons: Int(totals.reduce(0) { $0 + $1.gallons }.rounded()),
                             merma: seed.merma, status: seed.status, alertCount: seed.alertCount,
                             growth: seed.growth, sparkline: seed.sparkline)
        }
    }
    func franchise(_ id: String) -> Franchise? { franchises.first { $0.id == id } }
    func manager(for id: String) -> Manager? { managers.first { $0.id == assignments[id] } }
    @discardableResult func addStation(name: String, zone: String) -> String? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let zone = zone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !zone.isEmpty else { return nil }
        let id = UUID().uuidString
        seeds.append(Franchise(id: id, name: name, zone: zone, dailySales: 0, dailyGallons: 0,
                               merma: 0, status: .ok, alertCount: 0, growth: 0, sparkline: [0, 0, 0, 0, 0, 0]))
        fuelSeeds[id] = FuelType.allCases.map { FuelTotal(fuel: $0) }
        sucursales[id] = SucursalViewModel(id: id, tanks: Self.defaultTanks(id: id))
        let index = seeds.count - 1
        mapPositions[id] = MapPosition(x: CGFloat(35 + (index * 47) % 320), y: CGFloat(35 + (index * 31) % 170))
        persist()
        return id
    }
    @discardableResult func addManager(name: String, email: String, password: String) -> UUID? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty, email.contains("@"), !email.hasSuffix("@"), !email.hasPrefix("@"),
              password.count >= 4,
              !managers.contains(where: { $0.email == email }),
              email != generalAccount.email.lowercased() else { return nil }
        let manager = Manager(id: UUID(), name: name, email: email, password: password, role: "Gerente de sucursal")
        managers.append(manager)
        persist()
        return manager.id
    }
    @discardableResult func link(manager: UUID, station: String) -> Bool {
        guard managers.contains(where: { $0.id == manager }), seeds.contains(where: { $0.id == station }) else { return false }
        assignments[station] = manager
        persist()
        return true
    }

    func authenticateGeneral(email: String, password: String) -> Bool {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return clean == generalAccount.email.lowercased() && password == generalAccount.password
    }

    func authenticateFranchise(email: String, password: String) -> (stationId: String, name: String)? {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let manager = managers.first(where: { $0.email == clean && $0.password == password }) else { return nil }
        guard let entry = assignments.first(where: { $0.value == manager.id }) else { return nil }
        return (entry.key, manager.name)
    }
}

@Observable final class AdministracionViewModel {
    let general: GeneralViewModel
    var stationName = ""
    var zone = ""
    var managerName = ""
    var email = ""
    var password = ""
    var selectedManager: UUID?
    var selectedStation = ""
    var regularPriceText = ""
    var superPriceText = ""
    var dieselPriceText = ""
    var message: String?
    init(general: GeneralViewModel) { self.general = general }
    func addStation() {
        guard let id = general.addStation(name: stationName, zone: zone) else {
            message = "Completa el nombre y la zona de la estación."; return
        }
        selectedStation = id
        stationName = ""; zone = ""
        message = "Estación registrada con tres tanques al 60% y ventas en cero."
    }
    func addManager() {
        guard let id = general.addManager(name: managerName, email: email, password: password) else {
            message = "Escribe nombre, correo válido (no registrado) y contraseña de al menos 4 caracteres."
            return
        }
        selectedManager = id
        managerName = ""; email = ""; password = ""
        message = "Gerente creado. Ya puede iniciar sesión una vez lo vincules a una sucursal."
    }
    func link() {
        guard let manager = selectedManager, general.link(manager: manager, station: selectedStation) else {
            message = "Selecciona un gerente y una sucursal."; return
        }
        message = "Vínculo guardado."
    }
    func updatePrices() {
        var updated: [String] = []
        if let value = Self.parsePrice(regularPriceText), general.setPrice(value, for: .regular) { updated.append(FuelType.regular.label) }
        if let value = Self.parsePrice(superPriceText), general.setPrice(value, for: .superFuel) { updated.append(FuelType.superFuel.label) }
        if let value = Self.parsePrice(dieselPriceText), general.setPrice(value, for: .diesel) { updated.append(FuelType.diesel.label) }
        guard !updated.isEmpty else {
            message = "Escribe al menos un precio mayor a 0 y hasta 100."
            return
        }
        regularPriceText = ""; superPriceText = ""; dieselPriceText = ""
        message = "Precio actualizado: \(updated.joined(separator: ", "))."
    }
    private static func parsePrice(_ text: String) -> Double? {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard !clean.isEmpty, let value = Double(clean) else { return nil }
        return value
    }
}

@Observable final class ResumenViewModel {
    let general: GeneralViewModel
    var selectedId: String = ""
    init(general: GeneralViewModel) { self.general = general }
    var franchises: [Franchise] { general.franchises }
    var totals: [FuelTotal] { general.fuelTotals(for: selectedId.isEmpty ? nil : selectedId) }
    var revenue: String { totals.reduce(0) { $0 + $1.revenue }.formatted(.currency(code: "USD")) }
    var gallons: String { totals.reduce(0) { $0 + $1.gallons }.formatted(.number.precision(.fractionLength(2))) }
    var stationCount: String { String(selectedId.isEmpty ? franchises.count : 1) }
    var top: [Franchise] { Array(franchises.sorted { $0.dailyGallons > $1.dailyGallons }.prefix(5)) }
}

@Observable final class FranquiciasViewModel {
    let general: GeneralViewModel
    var search = ""
    var selectedPin: String?
    init(general: GeneralViewModel) { self.general = general }
    var franchises: [Franchise] { general.franchises }
    var filtered: [Franchise] {
        franchises.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.zone.localizedCaseInsensitiveContains(search) }
    }
    var selectedFranchise: Franchise? { selectedPin.flatMap { general.franchise($0) } }
    var mapPositions: [String: MapPosition] { general.mapPositions }
}

@Observable final class CompararViewModel {
    let general: GeneralViewModel
    var metric: CompareMetric = .gallons
    private(set) var selected = ["f1", "f2", "f3", "f4", "f9"]
    init(general: GeneralViewModel) { self.general = general }
    var franchises: [Franchise] { general.franchises }
    var selectedFranchises: [Franchise] { franchises.filter { selected.contains($0.id) } }
    var rows: [Franchise] { selectedFranchises.sorted { $0.value(for: metric) > $1.value(for: metric) } }
    func toggle(_ id: String) {
        if let index = selected.firstIndex(of: id) { selected.remove(at: index) }
        else { selected.append(id); if selected.count > 5 { selected.removeFirst() } }
    }
    func formattedValue(_ value: Double) -> String {
        switch metric {
        case .revenue: return value.formatted(.currency(code: "USD"))
        case .merma: return value.formatted() + "%"
        case .revPerGallon: return value.formatted(.number.precision(.fractionLength(2)))
        case .gallons: return value.formatted()
        }
    }
}

@Observable final class FranchiseDetailViewModel {
    let general: GeneralViewModel
    let id: String
    init(general: GeneralViewModel, id: String) { self.general = general; self.id = id }
    var franchise: Franchise? { general.franchise(id) }
    var sucursal: SucursalViewModel? { general.sucursales[id] }
    var managerName: String { general.manager(for: id)?.name ?? "Sin gerente vinculado" }
}
