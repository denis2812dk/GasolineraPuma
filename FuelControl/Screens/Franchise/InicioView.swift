import SwiftUI
import Charts

struct InicioView: View {
    @State var viewModel: InicioViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.name).font(.title.bold())
                Text(viewModel.zone).foregroundStyle(Theme.label2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    KPICard(title: "Ventas del día", value: viewModel.revenue)
                    KPICard(title: "Galones vendidos", value: viewModel.gallons)
                    KPICard(title: "Cortes cerrados", value: viewModel.closedCount)
                }
                ChartCardView(title: "Consumo por combustible (galones)") {
                    Chart(viewModel.totals) { total in
                        BarMark(x: .value("Combustible", total.fuel.label), y: .value("Galones", total.gallons))
                            .foregroundStyle(total.fuel.color)
                    }.frame(height: 180)
                }
                Text("Niveles de tanques").font(.headline)
                ForEach(viewModel.tanks) { tank in
                    HStack(spacing: 16) {
                        TankGaugeView(percentage: tank.percentage, fuelType: tank.fuelType)
                        FuelChip(type: tank.fuelType)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(tank.percentage)%").font(.title2.bold())
                            Text(tank.level.rawValue).foregroundStyle(tank.level.color)
                            Text("\(tank.current) gal").font(.caption)
                        }
                    }.padding().iosCard()
                }
            }.padding()
        }
        .background(Theme.background)
        .navigationTitle("Inicio")
    }
}
