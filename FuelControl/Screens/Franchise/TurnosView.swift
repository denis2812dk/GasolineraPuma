import SwiftUI

struct TurnosView: View {
    let onShiftSelect: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Turnos")
                    .font(.system(size: 28, weight: .bold))

                VStack(spacing: 12) {
                    ForEach(MockData.shifts) { shift in
                        Button {
                            onShiftSelect(shift.id)
                        } label: {
                            shiftRow(shift)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }

    private func shiftRow(_ shift: Shift) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Turno \(shift.number)").font(.system(size: 17, weight: .bold))
                    StatusBadge(shiftStatus: shift.status)
                }
                Text(shift.employee).font(.system(size: 13)).foregroundStyle(Theme.label2)
                Text("\(shift.startTime) \(shift.endTime.map { "→ \($0)" } ?? "→ en curso")")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.label2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if shift.gallonsSold > 0 {
                    Text("\(Format.grouped(shift.gallonsSold)) gal").font(.system(size: 15, weight: .bold))
                    Text(Format.dollars(shift.cashExpected)).font(.system(size: 12)).foregroundStyle(Theme.label2)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.3))
            }
        }
        .padding(16)
        .iosCard()
    }
}

#Preview {
    TurnosView(onShiftSelect: { _ in })
}
