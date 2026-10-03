import XCTest
@testable import FuelControlLogic

final class FuelControlLogicTests: XCTestCase {
    func testTwoCutsPerDayAndRollover() throws {
        var date = Date(timeIntervalSince1970: 1_790_928_000)
        let vm = SucursalViewModel(id: "test", tanks: [], now: { date })
        vm.ensureToday()
        XCTAssertEqual(vm.todayCortes.count, 2)
        XCTAssertEqual(Set(vm.todayCortes.map(\.turno)), Set(CorteTurno.allCases))
        date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 1, to: date))
        vm.ensureToday()
        vm.ensureToday()
        XCTAssertEqual(vm.todayCortes.count, 2)
        XCTAssertEqual(vm.cortes.count, 4)
    }

    func testSixExplicitRegistrationsAndClosedImmutability() throws {
        let vm = SucursalViewModel(id: "test", tanks: [])
        let id = try XCTUnwrap(vm.todayCortes.first?.id)
        XCTAssertFalse(vm.canClose(id))
        vm.register(id, pump: 1)
        XCTAssertFalse(try XCTUnwrap(vm.corte(id)?.entries.first?.registered))
        for pump in 1...6 {
            vm.update(id, pump: pump) {
                $0.fuel = pump <= 2 ? .regular : pump <= 4 ? .superFuel : .diesel
                $0.sales = "10,5"; $0.purchases = "2"; $0.losses = "0.5"
            }
            vm.register(id, pump: pump)
            if pump < 6 { XCTAssertFalse(vm.canClose(id)) }
        }
        XCTAssertTrue(vm.canClose(id))
        XCTAssertEqual(vm.total(id, category: .ventas), 63)
        for fuel in FuelType.allCases {
            XCTAssertEqual(vm.total(id, category: .ventas, fuel: fuel), 21)
            XCTAssertEqual(vm.total(id, category: .compras, fuel: fuel), 4)
            XCTAssertEqual(vm.total(id, category: .perdidas, fuel: fuel), 1)
        }
        vm.update(id, pump: 1) { $0.sales = "10.5" }
        XCTAssertFalse(vm.canClose(id))
        vm.register(id, pump: 1)
        vm.close(id)
        let closedAt = try XCTUnwrap(vm.corte(id)?.closedAt)
        vm.update(id, pump: 1) { $0.sales = "900" }
        vm.register(id, pump: 1)
        vm.close(id)
        XCTAssertEqual(vm.total(id, category: .ventas), 63)
        XCTAssertEqual(vm.corte(id)?.closedAt, closedAt)
        XCTAssertFalse(vm.canClose(id))
    }

    func testInvalidNumbersAndExplicitZero() {
        for invalid in ["", " ", "-1", "nan", "inf", "1e999", "1000001", "1,2,3", "abc"] {
            XCTAssertNil(SucursalViewModel.amount(invalid), invalid)
        }
        XCTAssertEqual(SucursalViewModel.amount("0"), 0)
        XCTAssertEqual(SucursalViewModel.amount(" 12,5 "), 12.5)
    }

    func testStationCreationPropagatesAndManagerLinkIsValidated() throws {
        let general = GeneralViewModel()
        let listing = FranquiciasViewModel(general: general)
        let comparison = CompararViewModel(general: general)
        let count = general.franchises.count
        XCTAssertNil(general.addStation(name: "  ", zone: "Centro"))
        let id = try XCTUnwrap(general.addStation(name: "Nueva", zone: "Oriente"))
        XCTAssertEqual(listing.franchises.count, count + 1)
        XCTAssertNotNil(listing.mapPositions[id])
        XCTAssertEqual(general.sucursales[id]?.tanks.count, 3)
        XCTAssertEqual(general.sucursales[id]?.todayCortes.count, 2)
        comparison.toggle(id)
        XCTAssertTrue(comparison.rows.contains { $0.id == id })
        XCTAssertEqual(general.franchise(id)?.value(for: .revPerGallon), 0)
        XCTAssertEqual(general.fuelTotals(for: id).reduce(0) { $0 + $1.gallons }, 0)
        XCTAssertNil(general.addManager(name: "Ana", email: "ANA@example.com", password: "abc"))
        let manager = try XCTUnwrap(general.addManager(name: "Ana", email: "ANA@example.com", password: "abcd"))
        XCTAssertNil(general.addManager(name: "Ana 2", email: "ana@example.com", password: "abcd"))
        XCTAssertFalse(general.link(manager: UUID(), station: id))
        XCTAssertFalse(general.link(manager: manager, station: "missing"))
        XCTAssertTrue(general.link(manager: manager, station: id))
        XCTAssertEqual(general.manager(for: id)?.name, "Ana")
    }

    func testAuthenticationForBothRoles() throws {
        let general = GeneralViewModel()
        XCTAssertTrue(general.authenticateGeneral(email: " Alejandro@FuelControl.com ", password: "puma2026"))
        XCTAssertFalse(general.authenticateGeneral(email: "alejandro@fuelcontrol.com", password: "wrong"))

        let loggedIn = try XCTUnwrap(general.authenticateFranchise(email: "maria@fuelcontrol.com", password: "turno123"))
        XCTAssertEqual(loggedIn.stationId, "f1")
        XCTAssertEqual(loggedIn.name, "María López")
        XCTAssertNil(general.authenticateFranchise(email: "maria@fuelcontrol.com", password: "wrong"))

        let unlinked = try XCTUnwrap(general.addManager(name: "Nuevo Gerente", email: "nuevo@fuelcontrol.com", password: "clave123"))
        XCTAssertNil(general.authenticateFranchise(email: "nuevo@fuelcontrol.com", password: "clave123"))
        let stationId = try XCTUnwrap(general.addStation(name: "Otra", zone: "Centro"))
        XCTAssertTrue(general.link(manager: unlinked, station: stationId))
        let afterLink = try XCTUnwrap(general.authenticateFranchise(email: "nuevo@fuelcontrol.com", password: "clave123"))
        XCTAssertEqual(afterLink.stationId, stationId)

        XCTAssertNil(general.addManager(name: "Impostor", email: "alejandro@fuelcontrol.com", password: "clave123"))
    }

    func testFuelPriceConfiguration() throws {
        let general = GeneralViewModel()
        XCTAssertEqual(general.price(.regular), 3.75)
        XCTAssertFalse(general.setPrice(0, for: .regular))
        XCTAssertFalse(general.setPrice(-1, for: .regular))
        XCTAssertFalse(general.setPrice(101, for: .regular))
        XCTAssertEqual(general.price(.regular), 3.75)
        XCTAssertTrue(general.setPrice(4.19, for: .regular))
        XCTAssertEqual(general.price(.regular), 4.19)

        let admin = AdministracionViewModel(general: general)
        admin.regularPriceText = "5,00"
        admin.updatePrices()
        XCTAssertEqual(general.price(.regular), 5.00)
        XCTAssertEqual(admin.regularPriceText, "")
    }

    func testConsolidatedDashboardIncludesOnlyClosedSalesOnce() throws {
        let general = GeneralViewModel()
        let baseline = general.fuelTotals().reduce(0) { $0 + $1.gallons }
        let id = try XCTUnwrap(general.addStation(name: "Nueva", zone: "Centro"))
        let vm = try XCTUnwrap(general.sucursales[id])
        let corte = try XCTUnwrap(vm.todayCortes.first?.id)
        for pump in 1...6 {
            vm.update(corte, pump: pump) { $0.sales = "10"; $0.purchases = "0"; $0.losses = "0" }
            vm.register(corte, pump: pump)
        }
        XCTAssertEqual(general.fuelTotals().reduce(0) { $0 + $1.gallons }, baseline)
        vm.close(corte)
        vm.close(corte)
        XCTAssertEqual(general.fuelTotals().reduce(0) { $0 + $1.gallons }, baseline + 60)
        XCTAssertEqual(general.fuelTotals(for: id).reduce(0) { $0 + $1.revenue }, 225)
    }

    func testPersistenceSurvivesReload() throws {
        PersistenceStore.clear()
        let general = GeneralViewModel()
        XCTAssertTrue(general.setPrice(5.25, for: .regular))
        let stationId = try XCTUnwrap(general.addStation(name: "Persistida", zone: "Centro"))
        let manager = try XCTUnwrap(general.addManager(name: "Temporal", email: "temporal@example.com", password: "abcd"))
        XCTAssertTrue(general.link(manager: manager, station: stationId))
        let vm = try XCTUnwrap(general.sucursales[stationId])
        let corte = try XCTUnwrap(vm.todayCortes.first?.id)
        vm.update(corte, pump: 1) { $0.sales = "12"; $0.purchases = "0"; $0.losses = "0" }
        vm.register(corte, pump: 1)

        let reloaded = GeneralViewModel()
        XCTAssertEqual(reloaded.price(.regular), 5.25)
        XCTAssertNotNil(reloaded.sucursales[stationId])
        XCTAssertEqual(reloaded.manager(for: stationId)?.name, "Temporal")
        XCTAssertTrue(try XCTUnwrap(reloaded.sucursales[stationId]?.corte(corte)?.entries.first?.registered))

        reloaded.resetToDemoData()
        let afterReset = GeneralViewModel()
        XCTAssertEqual(afterReset.price(.regular), 3.75)
        XCTAssertNil(afterReset.sucursales[stationId])
        PersistenceStore.clear()
    }

    func testTankLevelBoundariesAndSession() {
        XCTAssertEqual(TankLevel(percentage: 20), .critical)
        XCTAssertEqual(TankLevel(percentage: 21), .medium)
        XCTAssertEqual(TankLevel(percentage: 50), .medium)
        XCTAssertEqual(TankLevel(percentage: 51), .optimal)
        let session = SessionViewModel()
        session.login(role: .general, name: "Alejandro Rivas", email: "alejandro@fuelcontrol.com")
        XCTAssertEqual(session.role, .general)
        XCTAssertEqual(session.accountName, "Alejandro Rivas")
        session.logout()
        XCTAssertNil(session.role)
        XCTAssertEqual(session.accountName, "")
    }
}
