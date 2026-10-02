import SwiftUI
import Charts

struct SparklineView: View {
    let data: [Int]
    var color: Color = Theme.primary

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .interpolationMethod(.monotone)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: (data.min() ?? 0)...max((data.min() ?? 0) + 1, data.max() ?? 1))
        .frame(width: 60, height: 28)
    }
}
