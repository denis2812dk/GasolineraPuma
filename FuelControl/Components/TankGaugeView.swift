import SwiftUI

struct TankGaugeView: View {
    let percentage: Int
    let fuelType: FuelType
    var width: CGFloat = 22
    var height: CGFloat = 90

    private var fillColor: Color { TankLevel(percentage: percentage).color }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.subtleFill
            Rectangle()
                .fill(
                    LinearGradient(colors: [fillColor.opacity(0.75), fillColor], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: height * CGFloat(min(100, max(0, percentage))) / 100)
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
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
