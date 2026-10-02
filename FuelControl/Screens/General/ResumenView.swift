import SwiftUI
import Charts

struct ResumenView: View {
    @State var viewModel: ResumenViewModel
    var body: some View {
        @Bindable var model = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeroHeaderCard(
                    eyebrow: "Red de estaciones",
                    title: viewModel.selectedId.isEmpty ? "Todo el país" : (viewModel.franchises.first { $0.id == viewModel.selectedId }?.name ?? "Todo el país"),
                    icon: "map.fill",
                    colors: [Theme.primary, Color(hex: "1E63D6")]
                )
                Picker("Panorama", selection: $model.selectedId) {
                    Text("Todo el país").tag("")
                    ForEach(viewModel.franchises) { station in
                        Text(station.name).tag(station.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .iosCard()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(title: "Ingresos del día", value: viewModel.revenue, icon: "dollarsign.circle.fill")
                    KPICard(title: "Galones del día", value: viewModel.gallons, icon: "drop.fill")
                    KPICard(title: "Estaciones", value: viewModel.stationCount, icon: "building.2.fill")
                }
                ChartCardView(title: "Consumo por combustible", icon: "chart.bar.fill") {
                    Chart(viewModel.totals) { total in
                        BarMark(x: .value("Combustible", total.fuel.label), y: .value("Galones", total.gallons))
                            .foregroundStyle(total.fuel.color)
                    }.frame(height: 170)
                    ForEach(viewModel.totals) { total in
                        HStack {
                            FuelChip(type: total.fuel)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(total.gallons, format: .number.precision(.fractionLength(2))) + Text(" gal")
                                Text(total.revenue, format: .currency(code: "USD"))
                            }
                        }
                    }
                }
                if !viewModel.selectedId.isEmpty {
                    NavigationLink {
                        FranchiseDetailView(viewModel: FranchiseDetailViewModel(general: viewModel.general, id: viewModel.selectedId))
                    } label: {
                        navRow("Ver sucursal seleccionada", icon: "building.2.fill")
                    }
                }
                Label("Top sucursales por galones", systemImage: "trophy.fill").font(.headline)
                ForEach(viewModel.top) { station in
                    NavigationLink {
                        FranchiseDetailView(viewModel: FranchiseDetailViewModel(general: viewModel.general, id: station.id))
                    } label: {
                        HStack {
                            Text(station.name).foregroundStyle(.primary)
                            Spacer()
                            Text("\(station.dailyGallons) gal").foregroundStyle(Theme.label2)
                            SparklineView(data: station.sparkline, color: Theme.ok)
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.label3)
                        }.padding().iosCard()
                    }
                }
                NavigationLink {
                    AlertasListView(viewModel: AlertsViewModel(general: viewModel.general))
                } label: {
                    navRow("Alertas de la red", icon: "bell.fill")
                }
                NavigationLink {
                    AdministracionView(viewModel: AdministracionViewModel(general: viewModel.general))
                } label: {
                    navRow("Administración de estaciones y gerentes", icon: "building.2.crop.circle")
                }
            }.padding()
        }
        .background(Theme.background)
        .navigationTitle("Resumen")
    }

    private func navRow(_ title: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon).foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.label3)
        }
        .padding()
        .iosCard()
    }
}
