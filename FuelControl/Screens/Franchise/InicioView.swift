import SwiftUI
import Charts

struct InicioView: View {
    @State private var period = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estación Santa Ana Centro")
                        .font(.system(size: 28, weight: .bold))
                    Text("Zona Occidente · CL-0082")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.label2)
                }

                SegmentedControlView(options: ["Hoy", "Semana", "Mes"], selection: $period)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(title: "Ventas del día", value: "$12,450", change: "↑ 8% vs ayer", changeOk: true)
                    KPICard(title: "Galones vendidos", value: "3,210", sub: "galones", change: "↑ 5.2% vs ayer", changeOk: true)
                    KPICard(title: "Merma", value: "0.3%", change: "✓ Dentro del rango", changeOk: true, accent: Theme.ok)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Turno actual")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.label2)
                        Text("Turno 2")
                            .font(.system(size: 14, weight: .bold))
                        StatusBadge(shiftStatus: .abierto)
                        Text("María López · desde 14:00")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.label2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .iosCard()
                }

                ChartCardView(title: "Ventas por combustible (hoy)") {
                    Chart(MockData.hourlySalesData) { point in
                        BarMark(x: .value("Hora", point.hour), y: .value("Regular", point.regular))
                            .foregroundStyle(FuelType.regular.color)
                        BarMark(x: .value("Hora", point.hour), y: .value("Especial", point.especial))
                            .foregroundStyle(FuelType.especial.color)
                        BarMark(x: .value("Hora", point.hour), y: .value("Diésel", point.diesel))
                            .foregroundStyle(FuelType.diesel.color)
                    }
                    .chartXAxis {
                        AxisMarks(values: hourAxisTicks) { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .chartYAxis {
                        AxisMarks { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .frame(height: 160)

                    HStack(spacing: 12) {
                        ForEach([FuelType.regular, .especial, .diesel]) { fuel in
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2).fill(fuel.color).frame(width: 10, height: 10)
                                Text(fuel.label).font(.system(size: 10)).foregroundStyle(Theme.label2)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Niveles de tanques")
                        .font(.system(size: 17, weight: .semibold))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MockData.tanks) { tank in
                                tankCard(tank)
                            }
                        }
                    }
                }

                ChartCardView(title: "Ventas por hora (total $)") {
                    Chart(MockData.hourlySalesData) { point in
                        LineMark(x: .value("Hora", point.hour), y: .value("Total", point.total))
                            .foregroundStyle(Theme.primary)
                            .interpolationMethod(.monotone)
                    }
                    .chartXAxis {
                        AxisMarks(values: hourAxisTicks) { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .chartYAxis {
                        AxisMarks { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .frame(height: 130)
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    /// Every third hour label, to avoid crowding the x-axis.
    private var hourAxisTicks: [String] {
        MockData.hourlySalesData.enumerated().filter { $0.offset % 3 == 0 }.map(\.element.hour)
    }

    private func tankCard(_ tank: Tank) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                FuelChip(type: tank.fuelType)
                if tank.isLow {
                    Text("⚠ Bajo")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
            }
            HStack(alignment: .bottom, spacing: 12) {
                TankGaugeView(percentage: tank.percentage, fuelType: tank.fuelType, height: 80)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(tank.percentage)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(tank.isLow ? Theme.accent : .primary)
                    Text("\(Format.grouped(tank.current)) gal")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.label2)
                    Text("de \(Format.grouped(tank.capacity))")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.label3)
                }
            }
            Divider()
            HStack(spacing: 4) {
                Text("Autonomía:")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.label2)
                Text("\(tank.autonomyDays, specifier: "%.1f")d")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.7))
            }
        }
        .padding(12)
        .frame(width: 155, alignment: .leading)
        .iosCard()
    }
}

#Preview {
    InicioView()
}
