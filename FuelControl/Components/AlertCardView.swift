import SwiftUI

struct AlertCardView: View {
    let alert: AlertItem

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(alert.severity.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: alert.severity.systemImage)
                            .font(.system(size: 14))
                            .foregroundStyle(alert.severity.color)
                            .padding(.top, 1)
                        Text(alert.title)
                            .font(.system(size: 13, weight: .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Text(alert.timeAgo)
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.label2)
                }

                Text(alert.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.label2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 22)

                FuelChip(type: alert.category.relatedFuelType)
                    .padding(.leading, 22)
                    .padding(.top, 2)
            }
            .padding(12)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}
