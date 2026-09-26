import SwiftUI

struct IOSCardModifier: ViewModifier {
    var padding: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

extension View {
    /// Mirrors the `.ios-card` utility class from the original design.
    func iosCard(padding: CGFloat = 0) -> some View {
        modifier(IOSCardModifier(padding: padding))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var background: Color = Theme.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var iosPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func iosPrimary(background: Color) -> PrimaryButtonStyle { PrimaryButtonStyle(background: background) }
}

struct PillChipStyle: ViewModifier {
    var isSelected: Bool
    var selectedColor: Color = Theme.primary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? selectedColor : Color(hex: "787880").opacity(0.12))
            .foregroundStyle(isSelected ? .white : Color.black.opacity(0.7))
            .clipShape(Capsule())
    }
}

extension View {
    func pillChip(isSelected: Bool, selectedColor: Color = Theme.primary) -> some View {
        modifier(PillChipStyle(isSelected: isSelected, selectedColor: selectedColor))
    }
}
