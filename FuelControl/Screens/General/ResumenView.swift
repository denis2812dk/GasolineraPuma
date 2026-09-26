import SwiftUI
import Charts

struct ResumenView: View {
    let onFranchiseSelect: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Red de estaciones").font(.system(size: 28, weight: .bold))
                    Text("Sep 2026 · Todas las zonas").font(.system(size: 13)).foregroundStyle(Theme.label2)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(title: "Ingresos totales", value: "$186,300", change: "↑ 6.2% vs mes ant.", changeOk: true)
                    KPICard(title: "Galones totales", value: "48,900", sub: "galones", change: "↑ 4.8% vs mes ant.", changeOk: true)
                    KPICard(title: "Franquicias activas", value: "15", sub: "estaciones")
                    KPICard(title: "Alertas críticas", value: "3", sub: "requieren atención", accent: Theme.danger)
                }

                ChartCardView(title: "Este mes vs mes anterior ($)") {
                    Chart(MockData.monthlyComparisonData) { point in
                        LineMark(x: .value("Día", point.day), y: .value("Este mes", point.currentMonth))
                            .foregroundStyle(Theme.primary)
                            .interpolationMethod(.monotone)
                        LineMark(x: .value("Día", point.day), y: .value("Mes anterior", point.previousMonth))
                            .foregroundStyle(Theme.label3)
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 2]))
                            .interpolationMethod(.monotone)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 4)) { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .chartYAxis {
                        AxisMarks { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .frame(height: 140)

                    HStack(spacing: 16) {
                        legendLine(color: Theme.primary, label: "Este mes")
                        legendLine(color: Theme.label3, label: "Mes anterior")
                    }
                }

                fuelMixCard
                topFranchisesCard
                needsAttentionSection
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    private func legendLine(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 16, height: 2)
            Text(label).font(.system(size: 10)).foregroundStyle(Theme.label2)
        }
    }

    private var fuelMixCard: some View {
        let total = MockData.fuelMixData.reduce(0) { $0 + $1.value }
        return VStack(alignment: .leading, spacing: 4) {
            Text("Mezcla de combustible").font(.system(size: 13, weight: .semibold))
            HStack {
                Chart(MockData.fuelMixData) { item in
                    SectorMark(angle: .value("Valor", item.value), innerRadius: .ratio(0.6), angularInset: 2)
                        .foregroundStyle(item.color)
                }
                .frame(width: 130, height: 120)

                VStack(spacing: 8) {
                    ForEach(MockData.fuelMixData) { item in
                        HStack {
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2).fill(item.color).frame(width: 10, height: 10)
                                Text(item.name).font(.system(size: 12))
                            }
                            Spacer()
                            Text("\(Int((Double(item.value) / Double(total) * 100).rounded()))%")
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                }
            }
        }
        .padding(12)
        .iosCard()
    }

    private var topFranchisesCard: some View {
        let top = MockData.franchises.sorted { $0.dailyGallons > $1.dailyGallons }.prefix(5)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Top franquicias por galones").font(.system(size: 17, weight: .semibold))
            VStack(spacing: 0) {
                ForEach(Array(top.enumerated()), id: \.element.id) { i, f in
                    Button {
                        onFranchiseSelect(f.id)
                    } label: {
                        HStack(spacing: 12) {
                            Text("#\(i + 1)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Theme.label2)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(f.name).font(.system(size: 13, weight: .semibold))
                                Text(f.zone).font(.system(size: 11)).foregroundStyle(Theme.label2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Format.grouped(f.dailyGallons)) gal").font(.system(size: 13, weight: .semibold))
                                Text(Format.percent(f.growth))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(f.growth >= 0 ? Theme.ok : Theme.danger)
                            }
                            SparklineView(data: f.sparkline, color: Theme.ok)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.black.opacity(0.3))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if i < top.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .iosCard()
        }
    }

    private var needsAttentionSection: some View {
        let items = MockData.franchises.filter { MockData.needsAttentionIds.contains($0.id) }
        return VStack(alignment: .leading, spacing: 8) {
            Text("Requieren atención").font(.system(size: 17, weight: .semibold))
            VStack(spacing: 8) {
                ForEach(items) { f in
                    Button {
                        onFranchiseSelect(f.id)
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(f.status == .critical ? Theme.danger : Theme.accent)
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(f.name).font(.system(size: 13, weight: .semibold))
                                Text("\(f.status == .critical ? "🔴 Estado crítico" : "🟠 Requiere revisión") · Merma \(f.merma, specifier: "%.1f")%")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.label2)
                            }
                            Spacer()
                            Text("\(f.alertCount) alertas")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.danger)
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Color(hex: "FDECEA"))
                                .clipShape(Capsule())
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.black.opacity(0.3))
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .iosCard()
                }
            }
        }
    }
}

#Preview {
    ResumenView(onFranchiseSelect: { _ in })
}
