import SwiftUI
import Charts

struct VentasView: View {
    @State private var tab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ventas")
                    .font(.system(size: 28, weight: .bold))

                SegmentedControlView(options: ["Por bomba", "Por turno", "Por pago"], selection: $tab)

                switch tab {
                case 0: byPump
                case 1: byShift
                default: byPayment
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    private var byPump: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(MockData.pumps) { pump in
                    pumpCard(pump)
                }
            }

            ChartCardView(title: "Horas pico (tráfico %)") {
                heatmap
            }
        }
    }

    private func pumpCard(_ pump: Pump) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Bomba \(pump.number)")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                if pump.flagged != nil {
                    Text("⚠").font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.accent)
                }
            }
            ForEach(pump.fuels) { fuel in
                HStack {
                    FuelChip(type: fuel.type)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(Format.dollars(fuel.amount)).font(.system(size: 12, weight: .semibold))
                        Text("\(fuel.gallons) gal").font(.system(size: 10)).foregroundStyle(Theme.label2)
                    }
                }
            }
            if let flagged = pump.flagged {
                Divider()
                Text(flagged)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(12)
        .iosCard()
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .stroke(pump.flagged != nil ? Theme.accent : .clear, lineWidth: 2)
        )
    }

    private var heatmap: some View {
        let data = MockData.heatmapData
        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                Color.clear.frame(width: 28)
                ForEach(data.hours, id: \.self) { h in
                    Text(h).font(.system(size: 8)).foregroundStyle(Theme.label2)
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(Array(data.days.enumerated()), id: \.offset) { di, day in
                HStack(spacing: 2) {
                    Text(day)
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.label2)
                        .frame(width: 28, alignment: .trailing)
                    ForEach(Array(data.values[di].enumerated()), id: \.offset) { _, v in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.primary.opacity(Double(v) / 100))
                            .frame(height: 14)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            HStack {
                Spacer()
                LinearGradient(colors: [Theme.primary.opacity(0.1), Theme.primary], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 64, height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("Bajo → Alto").font(.system(size: 9)).foregroundStyle(Theme.label2)
            }
            .padding(.top, 2)
        }
    }

    private var byShift: some View {
        VStack(spacing: 12) {
            ForEach(MockData.shifts) { shift in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Turno \(shift.number)").font(.system(size: 15, weight: .bold))
                        StatusBadge(shiftStatus: shift.status)
                    }
                    Text("\(shift.employee) · \(shift.startTime)\(shift.endTime.map { " — \($0)" } ?? " (en curso)")")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.label2)

                    if shift.readings.isEmpty {
                        Text("Sin lecturas registradas")
                            .font(.system(size: 12))
                            .italic()
                            .foregroundStyle(Theme.label2)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(shift.readings) { r in
                                HStack {
                                    FuelChip(type: r.fuelType)
                                    Text(r.hoseId).font(.system(size: 12)).foregroundStyle(Theme.label2)
                                    Spacer()
                                    Text("\(r.gallons) gal").font(.system(size: 12, weight: .semibold))
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                        HStack {
                            Text("Total").font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("\(shift.gallonsSold) gal · \(Format.dollars(shift.cashExpected))")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(16)
                .iosCard()
            }
        }
    }

    private var byPayment: some View {
        let total = MockData.paymentData.reduce(0) { $0 + $1.value }
        return VStack(alignment: .leading, spacing: 12) {
            Text("Forma de pago").font(.system(size: 15, weight: .semibold))

            Chart(MockData.paymentData) { item in
                SectorMark(angle: .value("Monto", item.value), innerRadius: .ratio(0.6), angularInset: 2)
                    .foregroundStyle(item.color)
            }
            .frame(height: 160)

            VStack(spacing: 8) {
                ForEach(MockData.paymentData) { item in
                    HStack {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2).fill(item.color).frame(width: 12, height: 12)
                            Text(item.name).font(.system(size: 13))
                        }
                        Spacer()
                        Text(Format.dollars(item.value)).font(.system(size: 13, weight: .semibold))
                        Text("\(Int((Double(item.value) / Double(total) * 100).rounded()))%")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.label2)
                    }
                }
            }
        }
        .padding(16)
        .iosCard()
    }
}

#Preview {
    VentasView()
}
