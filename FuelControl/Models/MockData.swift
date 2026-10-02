import SwiftUI

/// Static sample data mirroring the original Figma prototype's `data.ts`.
/// Used only to seed local, in-memory ViewModels.
enum MockData {

    // MARK: - Franchise "Santa Ana Centro" (f1)

    static let tanks: [Tank] = [
        Tank(id: "t1", fuelType: .regular, capacity: 10000, current: 6500, temperature: 85, waterLevel: 0.1, lastReading: "16:32", autonomyDays: 3.2),
        Tank(id: "t2", fuelType: .superFuel, capacity: 8000, current: 1440, temperature: 84, waterLevel: 0.0, lastReading: "16:32", autonomyDays: 0.9),
        Tank(id: "t3", fuelType: .diesel, capacity: 12000, current: 9360, temperature: 83, waterLevel: 0.2, lastReading: "16:30", autonomyDays: 5.1),
    ]

    static let pumps: [Pump] = [
        Pump(id: "p1", number: 1, fuels: [
            PumpFuelSale(type: .regular, gallons: 312, amount: 1170),
            PumpFuelSale(type: .superFuel, gallons: 95, amount: 404),
        ], flagged: nil),
        Pump(id: "p2", number: 2, fuels: [
            PumpFuelSale(type: .regular, gallons: 298, amount: 1118),
            PumpFuelSale(type: .superFuel, gallons: 102, amount: 434),
        ], flagged: nil),
        Pump(id: "p3", number: 3, fuels: [
            PumpFuelSale(type: .regular, gallons: 325, amount: 1219),
            PumpFuelSale(type: .diesel, gallons: 188, amount: 658),
        ], flagged: nil),
        Pump(id: "p4", number: 4, fuels: [
            PumpFuelSale(type: .regular, gallons: 290, amount: 1088),
            PumpFuelSale(type: .diesel, gallons: 195, amount: 683),
        ], flagged: nil),
        Pump(id: "p5", number: 5, fuels: [
            PumpFuelSale(type: .superFuel, gallons: 88, amount: 374),
        ], flagged: nil),
        Pump(id: "p6", number: 6, fuels: [
            PumpFuelSale(type: .regular, gallons: 42, amount: 158),
            PumpFuelSale(type: .superFuel, gallons: 18, amount: 77),
            PumpFuelSale(type: .diesel, gallons: 35, amount: 123),
        ], flagged: "Venta inusualmente baja"),
    ]

    static let franchiseAlerts: [AlertItem] = [
        AlertItem(id: "a1", severity: .critical, category: .inventario, title: "Tanque Súper al 18%", description: "El tanque de Súper está por debajo del nivel mínimo aceptado (20%). Autonomía estimada: 0.9 días. Programar recepción urgente.", timeAgo: "hace 2h"),
        AlertItem(id: "a2", severity: .warning, category: .merma, title: "Venta inusualmente baja — Bomba 6", description: "La Bomba 6 registra ventas un 68% por debajo del promedio de las últimas 4 horas. Posible falla en el dispensador.", timeAgo: "hace 45 min"),
    ]

    static let inventoryRec = InventoryReconciliation(
        fuelType: .regular,
        initial: 9500, receptions: 2000, sales: 3210,
        theoretical: 8290, physical: 8210, difference: -80, differencePercent: -0.97
    )

    static let receptions: [Reception] = [
        Reception(id: "r1", date: "25 sep 2026", fuelType: .regular, invoiced: 2000, received: 1985),
        Reception(id: "r2", date: "22 sep 2026", fuelType: .diesel, invoiced: 3000, received: 2994),
        Reception(id: "r3", date: "18 sep 2026", fuelType: .superFuel, invoiced: 1500, received: 1492),
    ]

    // MARK: - Chart data

    static let hourlySalesData: [HourlySales] = [
        HourlySales(hour: "06", regular: 120, superFuel: 40, diesel: 30),
        HourlySales(hour: "07", regular: 180, superFuel: 60, diesel: 45),
        HourlySales(hour: "08", regular: 320, superFuel: 110, diesel: 80),
        HourlySales(hour: "09", regular: 410, superFuel: 140, diesel: 100),
        HourlySales(hour: "10", regular: 390, superFuel: 130, diesel: 95),
        HourlySales(hour: "11", regular: 450, superFuel: 150, diesel: 110),
        HourlySales(hour: "12", regular: 480, superFuel: 160, diesel: 115),
        HourlySales(hour: "13", regular: 520, superFuel: 175, diesel: 125),
        HourlySales(hour: "14", regular: 490, superFuel: 165, diesel: 120),
        HourlySales(hour: "15", regular: 430, superFuel: 145, diesel: 105),
        HourlySales(hour: "16", regular: 520, superFuel: 175, diesel: 125),
        HourlySales(hour: "17", regular: 610, superFuel: 205, diesel: 145),
        HourlySales(hour: "18", regular: 640, superFuel: 215, diesel: 155),
        HourlySales(hour: "19", regular: 580, superFuel: 195, diesel: 140),
        HourlySales(hour: "20", regular: 520, superFuel: 175, diesel: 125),
        HourlySales(hour: "21", regular: 440, superFuel: 150, diesel: 105),
        HourlySales(hour: "22", regular: 320, superFuel: 110, diesel: 80),
    ]

    static let paymentData: [PaymentMethod] = [
        PaymentMethod(name: "Efectivo", value: 4650, color: Theme.primary),
        PaymentMethod(name: "Tarjeta", value: 5830, color: Theme.ok),
        PaymentMethod(name: "Crédito/Flota", value: 1970, color: Theme.accent),
    ]

    static let heatmapData = HeatmapData(
        days: ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"],
        hours: ["06", "08", "10", "12", "14", "16", "18", "20", "22"],
        values: [
            [45, 60, 75, 80, 70, 75, 85, 70, 55],
            [40, 55, 70, 75, 65, 70, 80, 65, 50],
            [45, 60, 75, 78, 68, 72, 82, 67, 52],
            [50, 65, 80, 85, 75, 80, 90, 75, 60],
            [55, 70, 85, 90, 80, 85, 95, 82, 68],
            [60, 75, 90, 95, 85, 90, 100, 88, 72],
            [35, 50, 65, 70, 60, 65, 75, 62, 48],
        ]
    )

    static let monthlyComparisonData: [MonthlyComparisonPoint] = (0..<26).map { i in
        let d = Double(i)
        return MonthlyComparisonPoint(
            day: i + 1,
            currentMonth: Int((5200 + d * 290 + sin(d * 0.5) * 800).rounded()),
            previousMonth: Int((4800 + d * 260 + sin(d * 0.5 + 1) * 700).rounded())
        )
    }

    static let fuelMixData: [FuelMixSlice] = [
        FuelMixSlice(name: "Regular", value: 32400, color: Theme.ok),
        FuelMixSlice(name: "Súper", value: 9800, color: Theme.danger),
        FuelMixSlice(name: "Diésel", value: 6700, color: Color(hex: "5F6368")),
    ]

    // MARK: - Network franchises

    static let franchises: [Franchise] = [
        Franchise(id: "f1", name: "Santa Ana Centro", zone: "Occidente", dailySales: 12450, dailyGallons: 3210, merma: 0.3, status: .ok, alertCount: 1, growth: 8.0, sparkline: [2800, 2950, 3100, 2950, 3050, 3210]),
        Franchise(id: "f2", name: "Santa Ana Norte", zone: "Occidente", dailySales: 19200, dailyGallons: 4880, merma: 0.4, status: .ok, alertCount: 0, growth: 12.3, sparkline: [4200, 4400, 4600, 4500, 4700, 4880]),
        Franchise(id: "f3", name: "Las Américas", zone: "Centro", dailySales: 16800, dailyGallons: 4420, merma: 0.5, status: .warning, alertCount: 2, growth: -1.8, sparkline: [4800, 4600, 4500, 4400, 4420, 4420]),
        Franchise(id: "f4", name: "Centro Histórico", zone: "Centro", dailySales: 15600, dailyGallons: 4080, merma: 0.2, status: .ok, alertCount: 0, growth: 5.4, sparkline: [3700, 3800, 3900, 3950, 4000, 4080]),
        Franchise(id: "f5", name: "Colonia Escalón", zone: "Centro", dailySales: 9600, dailyGallons: 2560, merma: 0.6, status: .warning, alertCount: 1, growth: 2.1, sparkline: [2400, 2450, 2500, 2480, 2520, 2560]),
        Franchise(id: "f6", name: "Antiguo Cuscatlán", zone: "Centro", dailySales: 14500, dailyGallons: 3835, merma: 0.3, status: .warning, alertCount: 1, growth: 4.5, sparkline: [3500, 3600, 3700, 3750, 3800, 3835]),
        Franchise(id: "f7", name: "Soyapango", zone: "Oriente", dailySales: 12800, dailyGallons: 3395, merma: 0.4, status: .ok, alertCount: 0, growth: 6.7, sparkline: [3000, 3100, 3200, 3250, 3350, 3395]),
        Franchise(id: "f8", name: "Apopa", zone: "Norte", dailySales: 11200, dailyGallons: 2955, merma: 0.3, status: .ok, alertCount: 0, growth: 9.2, sparkline: [2600, 2700, 2750, 2800, 2900, 2955]),
        Franchise(id: "f9", name: "San Marcos", zone: "Oriente", dailySales: 7800, dailyGallons: 2075, merma: 1.8, status: .critical, alertCount: 3, growth: -4.5, sparkline: [2400, 2300, 2200, 2150, 2100, 2075]),
        Franchise(id: "f10", name: "Quezaltepeque", zone: "Norte", dailySales: 10200, dailyGallons: 2685, merma: 0.4, status: .critical, alertCount: 2, growth: 1.3, sparkline: [2600, 2620, 2640, 2650, 2670, 2685]),
        Franchise(id: "f11", name: "Mejicanos", zone: "Norte", dailySales: 13500, dailyGallons: 3545, merma: 0.5, status: .ok, alertCount: 1, growth: 7.8, sparkline: [3100, 3200, 3300, 3400, 3480, 3545]),
        Franchise(id: "f12", name: "Ilopango", zone: "Oriente", dailySales: 10800, dailyGallons: 2855, merma: 0.3, status: .ok, alertCount: 0, growth: 3.4, sparkline: [2700, 2730, 2760, 2790, 2820, 2855]),
        Franchise(id: "f13", name: "Tonacatepeque", zone: "Norte", dailySales: 9500, dailyGallons: 2520, merma: 0.4, status: .ok, alertCount: 0, growth: 11.2, sparkline: [2100, 2200, 2300, 2380, 2460, 2520]),
        Franchise(id: "f14", name: "Zacatecoluca", zone: "Paracentral", dailySales: 10200, dailyGallons: 2690, merma: 0.6, status: .warning, alertCount: 1, growth: -2.3, sparkline: [2900, 2850, 2800, 2750, 2700, 2690]),
        Franchise(id: "f15", name: "San Vicente", zone: "Paracentral", dailySales: 12150, dailyGallons: 3200, merma: 0.3, status: .ok, alertCount: 0, growth: 8.9, sparkline: [2800, 2900, 2980, 3050, 3120, 3200]),
    ]

    static let needsAttentionIds: Set<String> = ["f9", "f10", "f3", "f6"]

    static let generalAlerts: [AlertItem] = [
        AlertItem(id: "ga1", severity: .critical, category: .inventario, title: "Quezaltepeque: Tanque Regular al 12%", description: "Nivel crítico. Autonomía estimada: 0.6 días. Recepción urgente requerida.", timeAgo: "hace 1h"),
        AlertItem(id: "ga2", severity: .critical, category: .merma, title: "San Marcos: Merma 1.8% fuera de tolerancia", description: "Supera el límite máximo permitido (0.8%). Requiere auditoría inmediata del inventario.", timeAgo: "hace 3h"),
        AlertItem(id: "ga4", severity: .warning, category: .inventario, title: "Las Américas: Tanque Diésel al 22%", description: "Nivel de Diésel cercano al límite mínimo. Programar recepción en las próximas 24h.", timeAgo: "hace 2h"),
        AlertItem(id: "ga5", severity: .warning, category: .pipas, title: "Soyapango: Diferencia en recepción", description: "Diferencia de 45 galones entre facturado (3,000) y recibido (2,955). Revisar acta de recepción.", timeAgo: "hace 6h"),
        AlertItem(id: "ga6", severity: .info, category: .merma, title: "Colonia Escalón: Merma en límite", description: "La merma acumulada del mes alcanzó 0.6%, acercándose al umbral de alerta (0.8%).", timeAgo: "hace 5h"),
    ]

    /// Map positions for franchise pins, on a 393x250 canvas (matches the SwiftUI map canvas size).
    static let franchiseMapPositions: [String: MapPosition] = [
        "f1": MapPosition(x: 68, y: 148), "f2": MapPosition(x: 55, y: 100),
        "f3": MapPosition(x: 178, y: 110), "f4": MapPosition(x: 168, y: 148),
        "f5": MapPosition(x: 190, y: 130), "f6": MapPosition(x: 155, y: 165),
        "f7": MapPosition(x: 282, y: 130), "f8": MapPosition(x: 140, y: 68),
        "f9": MapPosition(x: 265, y: 160), "f10": MapPosition(x: 120, y: 58),
        "f11": MapPosition(x: 162, y: 82), "f12": MapPosition(x: 295, y: 155),
        "f13": MapPosition(x: 148, y: 52), "f14": MapPosition(x: 198, y: 195),
        "f15": MapPosition(x: 228, y: 188),
    ]
}
