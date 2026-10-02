import SwiftUI
import Observation

@Observable final class GeneralViewModel {
    private var seeds: [Franchise]
    private var fuelSeeds: [String: [FuelTotal]] = [:]
    private(set) var managers: [Manager] = []
    private(set) var assignments: [String: UUID] = [:]
    private(set) var sucursales: [String: SucursalViewModel] = [:]
    private(set) var mapPositions: [String: MapPosition]

    init() {
        seeds = MockData.franchises
        mapPositions = MockData.franchiseMapPositions
        for franchise in seeds {
            // Local sample breakdown. Integer remainders preserve the source totals exactly.
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
            sucursales[franchise.id] = SucursalViewModel(id: franchise.id, tanks: tanks,
                inventoryRec: franchise.id == "f1" ? MockData.inventoryRec : nil,
                receptions: franchise.id == "f1" ? MockData.receptions : [])
        }
    }
    static func defaultTanks(id: String) -> [Tank] {
        FuelType.allCases.map {
            Tank(id: "\(id)-\($0.rawValue)", fuelType: $0, capacity: 10000, current: 6000,
                 temperature: 84, waterLevel: 0, lastReading: "Inicial", autonomyDays: 3)
        }
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
    func price(_ fuel: FuelType) -> Double {
        switch fuel {
        case .regular: return 3.75
        case .superFuel: return 4.25
        case .diesel: return 3.50
        }
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
        return id
    }
    @discardableResult func addManager(name: String, email: String) -> UUID? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty, email.contains("@"), !email.hasSuffix("@"), !email.hasPrefix("@"),
              !managers.contains(where: { $0.email == email }) else { return nil }
        let manager = Manager(id: UUID(), name: name, email: email, role: "Gerente de sucursal")
        managers.append(manager)
        return manager.id
    }
    @discardableResult func link(manager: UUID, station: String) -> Bool {
        guard managers.contains(where: { $0.id == manager }), seeds.contains(where: { $0.id == station }) else { return false }
        assignments[station] = manager
        return true
    }
}

@Observable final class AdministracionViewModel {
    let general: GeneralViewModel
    var stationName = ""
    var zone = ""
    var managerName = ""
    var email = ""
    var selectedManager: UUID?
    var selectedStation = ""
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
        guard let id = general.addManager(name: managerName, email: email) else {
            message = "Escribe un nombre y correo válido que no esté registrado."; return
        }
        selectedManager = id
        managerName = ""; email = ""
        message = "Gerente creado. Ya puedes vincularlo a una sucursal."
    }
    func link() {
        guard let manager = selectedManager, general.link(manager: manager, station: selectedStation) else {
            message = "Selecciona un gerente y una sucursal."; return
        }
        message = "Vínculo guardado."
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
