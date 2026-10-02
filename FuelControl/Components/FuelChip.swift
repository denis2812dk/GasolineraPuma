import SwiftUI

struct FuelChip: View {
    let type: FuelType

    var body: some View {
        Text(type.label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(type.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct StatusBadge: View {
    let label: String
    let color: Color

    init(franchiseStatus: FranchiseStatus) {
        label = franchiseStatus.label
        color = franchiseStatus.color
    }

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
