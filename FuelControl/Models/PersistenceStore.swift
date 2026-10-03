import Foundation

struct SucursalSnapshot: Codable {
    var tanks: [Tank]
    var cortes: [Corte]
    var inventoryRec: InventoryReconciliation?
    var receptions: [Reception]
}

struct PersistedState: Codable {
    var franchises: [Franchise]
    var fuelSeeds: [String: [FuelTotal]]
    var managers: [Manager]
    var assignments: [String: UUID]
    var mapPositions: [String: MapPosition]
    var prices: [FuelType: Double]
    var sucursales: [String: SucursalSnapshot]
}

enum PersistenceStore {
    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("fuelcontrol_state.json")
    }

    static func save(_ state: PersistedState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func load() -> PersistedState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
