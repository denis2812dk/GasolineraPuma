import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift

    private var diff: Int { shift.cashDeclared - shift.cashExpected }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                readingsSection
                cashSection
                actionButton
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
        .navigationTitle("Turno \(shift.number)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Turno \(shift.number)").font(.system(size: 20, weight: .bold))
                Text(shift.employee).font(.system(size: 14)).foregroundStyle(Theme.label2)
                Text("\(shift.startTime) \(shift.endTime.map { "→ \($0)" } ?? "→ en curso")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.label2)
            }
            Spacer()
            StatusBadge(shiftStatus: shift.status)
        }
        .padding(16)
        .iosCard()
    }

    private var readingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lecturas de totalizador").font(.system(size: 17, weight: .semibold))

            VStack(spacing: 0) {
                HStack {
                    Text("Manguera").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Inicial").frame(maxWidth: .infinity, alignment: .trailing)
                    Text("Final").frame(maxWidth: .infinity, alignment: .trailing)
                    Text("Galones").frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.label2)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 6)

                if shift.readings.isEmpty {
                    Text("Sin lecturas registradas")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.label2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    ForEach(shift.readings) { r in
                        Divider()
                        HStack {
                            HStack(spacing: 6) {
                                FuelChip(type: r.fuelType)
                                Text(r.hoseId).font(.system(size: 12)).foregroundStyle(Theme.label2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(Format.grouped(r.initial))").font(.system(size: 12)).frame(maxWidth: .infinity, alignment: .trailing)
                            Text("\(Format.grouped(r.final))").font(.system(size: 12)).frame(maxWidth: .infinity, alignment: .trailing)
                            Text("\(r.gallons)").font(.system(size: 12, weight: .semibold)).frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .iosCard()
        }
    }

    private var cashSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cuadre de caja").font(.system(size: 17, weight: .semibold))

            VStack(spacing: 0) {
                HStack {
                    Text("Efectivo esperado").font(.system(size: 13)).foregroundStyle(Theme.label2)
                    Spacer()
                    Text(Format.dollars(shift.cashExpected)).font(.system(size: 13, weight: .semibold))
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("Efectivo declarado").font(.system(size: 13)).foregroundStyle(Theme.label2)
                    Spacer()
                    Text(Format.dollars(shift.cashDeclared)).font(.system(size: 13, weight: .semibold))
                }
                .padding(.vertical, 8)

                HStack {
                    Text("Diferencia")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(diff == 0 ? Theme.ok : Theme.accent)
                    Spacer()
                    Text("\(diff >= 0 ? "+" : "")\(Format.dollars(diff))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(diff == 0 ? Theme.ok : Theme.accent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(diff == 0 ? Color(hex: "E8F5E9") : Color(hex: "FFF3E0"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.top, 4)
            }
            .padding(16)
            .iosCard()
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch shift.status {
        case .abierto:
            Button("Cerrar turno") {}
                .buttonStyle(.iosPrimary)
        case .pendiente:
            Button("Abrir turno") {}
                .buttonStyle(.iosPrimary(background: Theme.ok))
        case .cerrado:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        ShiftDetailView(shift: MockData.shifts[0])
    }
}
