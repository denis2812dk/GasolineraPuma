import SwiftUI
import Charts

struct InicioView: View {
    @State var viewModel: InicioViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeroHeaderCard(eyebrow: viewModel.zone, title: viewModel.name, icon: "fuelpump.fill")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(title: "Ventas del día", value: viewModel.revenue, icon: "dollarsign.circle.fill")
                    KPICard(title: "Galones vendidos", value: viewModel.gallons, icon: "drop.fill")
                    KPICard(title: "Cortes cerrados", value: viewModel.closedCount, icon: "checkmark.seal.fill")
                }
                ChartCardView(title: "Consumo por combustible (galones)", icon: "chart.bar.fill") {
                    Chart(viewModel.totals) { total in
                        BarMark(x: .value("Combustible", total.fuel.label), y: .value("Galones", total.gallons))
                            .foregroundStyle(total.fuel.color)
                            .cornerRadius(6)
                    }.frame(height: 180)
                }
                Label("Niveles de tanques", systemImage: "gauge.with.dots.needle.33percent")
                    .font(.headline)
                ForEach(viewModel.tanks) { tank in
                    HStack(spacing: 16) {
                        TankGaugeView(percentage: tank.percentage, fuelType: tank.fuelType, width: 60, height: 60)
                        VStack(alignment: .leading, spacing: 3) {
                            FuelChip(type: tank.fuelType)
                            Text(tank.level.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(tank.level.color)
                        }
                        Spacer()
                        Text("\(tank.current) gal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.label2)
                    }.padding().iosCard()
                }
            }.padding()
        }
        .background(Theme.background)
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
