import SwiftUI
import Charts

struct CompararView: View {
    @State var viewModel: CompararViewModel
    private let barColors: [Color] = [Theme.primary, Theme.ok, Theme.accent, Theme.danger, Color(hex: "5F6368")]

    private func color(for franchiseId: String) -> Color {
        guard let idx = viewModel.selected.firstIndex(of: franchiseId) else { return Theme.label2 }
        return barColors[idx % barColors.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Comparar").font(.system(size: 28, weight: .bold))

                SegmentedControlView(
                    options: CompareMetric.allCases.map(\.shortLabel),
                    selection: Binding(
                        get: { CompareMetric.allCases.firstIndex(of: viewModel.metric) ?? 0 },
                        set: { viewModel.metric = CompareMetric.allCases[$0] }
                    )
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.franchises) { f in
                            Button {
                                viewModel.toggle(f.id)
                            } label: {
                                Text(f.name.components(separatedBy: " ").first ?? f.name)
                                    .pillChip(isSelected: viewModel.selected.contains(f.id), selectedColor: color(for: f.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ChartCardView(title: "Comparación por \(viewModel.metric.label)") {
                    Chart(viewModel.selectedFranchises) { f in
                        BarMark(
                            x: .value("Franquicia", f.name.components(separatedBy: " ").first ?? f.name),
                            y: .value(viewModel.metric.label, f.value(for: viewModel.metric))
                        )
                        .foregroundStyle(color(for: f.id))
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .chartYAxis {
                        AxisMarks { AxisValueLabel().font(.system(size: 9)) }
                    }
                    .frame(height: 160)
                }

                comparisonTable
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    private var comparisonTable: some View {
        let rows = viewModel.rows
        return VStack(alignment: .leading, spacing: 8) {
            Text("Tabla de comparación").font(.system(size: 17, weight: .semibold))
            VStack(spacing: 0) {
                HStack {
                    Text("Franquicia").frame(maxWidth: .infinity, alignment: .leading)
                    Text(viewModel.metric.label).frame(width: 70, alignment: .trailing)
                    Text("Crec.").frame(width: 56, alignment: .trailing)
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.label2)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.background)

                ForEach(rows) { f in
                    Divider()
                    HStack {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2).fill(color(for: f.id)).frame(width: 10, height: 10)
                            Text(f.name).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(viewModel.formattedValue(f.value(for: viewModel.metric)))
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 70, alignment: .trailing)
                        Text(Format.percent(f.growth))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(f.growth >= 0 ? Theme.ok : Theme.danger)
                            .frame(width: 56, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .iosCard()
        }
    }
}
