import SwiftUI

struct FuelChip: View {
    let type: FuelType

    var body: some View {
        Text(type.label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(type.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct StatusBadge: View {
    let label: String
    let color: Color
    let backgroundColor: Color

    init(franchiseStatus: FranchiseStatus) {
        label = franchiseStatus.label
        color = franchiseStatus.color
        backgroundColor = franchiseStatus.backgroundColor
    }

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}
