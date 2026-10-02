import SwiftUI

struct TanquesView: View {
    @State var viewModel: TanquesViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tanques")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 4)

                ForEach(viewModel.tanks) { tank in
                    tankDetailCard(tank)
                }

                Text("Crítico: hasta 20% · Medio: más de 20% hasta 50% · Óptimo: más de 50%")
                    .font(.caption).foregroundStyle(.secondary)
                if let rec = viewModel.inventoryRec { reconciliationCard(rec) }
                if !viewModel.receptions.isEmpty { receptionsCard }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    private func tankDetailCard(_ tank: Tank) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    FuelChip(type: tank.fuelType)
                    Text(tank.level.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(tank.level.color)
                }
                Spacer()
                Text("Última lectura: \(tank.lastReading)")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.label2)
            }

            HStack(alignment: .bottom, spacing: 16) {
                TankGaugeView(percentage: tank.percentage, fuelType: tank.fuelType, height: 110)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(tank.percentage)%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(tank.level.color)
                    Text("\(Format.grouped(tank.current)) / \(Format.grouped(tank.capacity)) gal")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.label2)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 4) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Temperatura").font(.system(size: 10)).foregroundStyle(Theme.label2)
                            Text("\(tank.temperature)°F").font(.system(size: 13, weight: .semibold))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Nivel agua").font(.system(size: 10)).foregroundStyle(Theme.label2)
                            Text("\(tank.waterLevel, specifier: "%.1f")%").font(.system(size: 13, weight: .semibold))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Autonomía estimada").font(.system(size: 10)).foregroundStyle(Theme.label2)
                            Text("\(tank.autonomyDays, specifier: "%.1f") días")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(tank.level.color)
                        }
                        .gridCellColumns(2)
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .iosCard()
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .stroke(tank.level.color, lineWidth: 2)
        )
    }

    private struct ReconciliationRow: Identifiable {
        let label: String
        let value: Int
        let isBold: Bool
        var id: String { label }
    }

    private func reconciliationCard(_ rec: InventoryReconciliation) -> some View {
        let rows: [ReconciliationRow] = [
            ReconciliationRow(label: "Inventario inicial", value: rec.initial, isBold: false),
            ReconciliationRow(label: "+ Recepciones", value: rec.receptions, isBold: false),
            ReconciliationRow(label: "− Ventas", value: rec.sales, isBold: false),
            ReconciliationRow(label: "= Teórico", value: rec.theoretical, isBold: true),
        ]
        return VStack(alignment: .leading, spacing: 8) {
            Text("Conciliación de inventario").font(.system(size: 15, weight: .semibold))
            HStack(spacing: 8) {
                FuelChip(type: rec.fuelType)
                Text("Regular · hoy").font(.system(size: 12)).foregroundStyle(Theme.label2)
            }

            VStack(spacing: 0) {
                ForEach(rows) { row in
                    HStack {
                        Text(row.label).font(.system(size: 13)).foregroundStyle(Theme.label2)
                        Spacer()
                        Text("\(Format.grouped(row.value)) gal")
                            .font(.system(size: 13, weight: row.isBold ? .bold : .medium))
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
                HStack {
                    Text("Físico medido").font(.system(size: 13)).foregroundStyle(Theme.label2)
                    Spacer()
                    Text("\(Format.grouped(rec.physical)) gal").font(.system(size: 13, weight: .medium))
                }
                .padding(.vertical, 6)
                Divider()
            }

            HStack {
                Text("Diferencia").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.accent)
                Spacer()
                Text("\(rec.difference) gal (\(rec.differencePercent, specifier: "%.2f")%)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "FFF3E0"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(.top, 2)
        }
        .padding(16)
        .iosCard()
    }

    private var receptionsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recepciones de pipa").font(.system(size: 15, weight: .semibold))

            VStack(spacing: 0) {
                ForEach(viewModel.receptions) { rec in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            HStack(spacing: 8) {
                                FuelChip(type: rec.fuelType)
                                Text(rec.date).font(.system(size: 12)).foregroundStyle(Theme.label2)
                            }
                            Spacer()
                            Text(rec.isWithinTolerance ? "OK" : "Diferencia")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(rec.isWithinTolerance ? Theme.ok : Theme.accent)
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(rec.isWithinTolerance ? Color(hex: "E8F5E9") : Color(hex: "FFF3E0"))
                                .clipShape(Capsule())
                        }
                        HStack {
                            HStack(spacing: 3) {
                                Text("Facturado:").font(.system(size: 12)).foregroundStyle(Theme.label2)
                                Text("\(Format.grouped(rec.invoiced)) gal").font(.system(size: 12, weight: .medium))
                            }
                            Spacer()
                            HStack(spacing: 3) {
                                Text("Recibido:").font(.system(size: 12)).foregroundStyle(Theme.label2)
                                Text("\(Format.grouped(rec.received)) gal").font(.system(size: 12, weight: .medium))
                            }
                        }
                        Text("Diferencia: \(rec.difference) gal (\(rec.differencePercent, specifier: "%.2f")%)")
                            .font(.system(size: 11))
                            .foregroundStyle(rec.isWithinTolerance ? Theme.ok : Theme.accent)
                    }
                    .padding(.vertical, 10)
                    Divider()
                }
            }
        }
        .padding(16)
        .iosCard()
    }
}
