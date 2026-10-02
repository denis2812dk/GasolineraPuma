import SwiftUI

struct IOSCardModifier: ViewModifier {
    var padding: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 5)
    }
}

extension View {
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
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [background, background.opacity(0.82)], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AnyShapeStyle(selectedColor) : AnyShapeStyle(Theme.subtleFill))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}

extension View {
    func pillChip(isSelected: Bool, selectedColor: Color = Theme.primary) -> some View {
        modifier(PillChipStyle(isSelected: isSelected, selectedColor: selectedColor))
    }
}
