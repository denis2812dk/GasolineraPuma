import SwiftUI

struct TankGaugeView: View {
    let percentage: Int
    let fuelType: FuelType
    var width: CGFloat = 70
    var height: CGFloat = 70

    private var clamped: Int { min(100, max(0, percentage)) }
    private var progress: Double { Double(clamped) / 100 }
    private var fillColor: Color { TankLevel(percentage: percentage).color }
    private var diameter: CGFloat { min(width, height) }
    private var lineWidth: CGFloat { max(5, diameter * 0.12) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.subtleFill, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(progress, 0.001))
                .stroke(
                    AngularGradient(
                        colors: [fillColor.opacity(0.55), fillColor],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * progress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: percentage)

            VStack(spacing: 0) {
                Text("\(clamped)")
                    .font(.system(size: diameter * 0.26, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text("%")
                    .font(.system(size: diameter * 0.13, weight: .semibold))
                    .foregroundStyle(Theme.label2)
            }
        }
        .frame(width: width, height: height)
    }
}
