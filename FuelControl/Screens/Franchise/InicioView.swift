import SwiftUI
import Charts

struct InicioView: View {
    @State var viewModel: InicioViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.name).font(.largeTitle.bold())
                    Text(viewModel.zone).font(.subheadline).foregroundStyle(Theme.label2)
                }
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
                        TankGaugeView(percentage: tank.percentage, fuelType: tank.fuelType)
                        FuelChip(type: tank.fuelType)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(tank.percentage)%").font(.title2.bold())
                            Text(tank.level.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(tank.level.color)
                            Text("\(tank.current) gal").font(.caption).foregroundStyle(Theme.label2)
                        }
                    }.padding().iosCard()
                }
            }.padding()
        }
        .background(Theme.background)
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
