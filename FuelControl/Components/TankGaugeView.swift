import SwiftUI

struct TankGaugeView: View {
    let percentage: Int
    let fuelType: FuelType
    var width: CGFloat = 22
    var height: CGFloat = 90

    private var isLow: Bool { percentage <= 20 }
    private var isCritical: Bool { percentage <= 10 }

    private var fillColor: Color {
        if isCritical { return Theme.danger }
        if isLow { return Theme.accent }
        return fuelType.color
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "F1F1F1")
            Rectangle()
                .fill(fillColor)
                .frame(height: height * CGFloat(percentage) / 100)
                .animation(.easeInOut(duration: 0.5), value: percentage)

            ForEach([0.75, 0.5, 0.25] as [Double], id: \.self) { tick in
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, 4)
                    .padding(.bottom, height * CGFloat(tick))
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
        )
    }
}
