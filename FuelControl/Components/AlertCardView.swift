import SwiftUI

struct AlertCardView: View {
    let alert: AlertItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(alert.severity.color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: alert.severity.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(alert.severity.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(alert.title)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Text(alert.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(Theme.label2)
                }

                Text(alert.description)
                    .font(.footnote)
                    .foregroundStyle(Theme.label2)
                    .fixedSize(horizontal: false, vertical: true)

                if let fuel = alert.fuelType {
                    FuelChip(type: fuel).padding(.top, 2)
                }
            }
        }
        .padding(12)
        .iosCard()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(alert.severity.color)
                .frame(width: 4)
                .padding(.vertical, 10)
        }
    }
}
