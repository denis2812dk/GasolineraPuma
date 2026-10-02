import SwiftUI

struct KPICard: View {
    let title: String
    let value: String
    var sub: String? = nil
    var change: String? = nil
    var changeOk: Bool = true
    var accent: Color? = nil
    var icon: String? = nil

    private var tint: Color { accent ?? Theme.primary }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(tint.gradient)
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(accent ?? .primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.label2)
            if let sub {
                Text(sub)
                    .font(.caption2)
                    .foregroundStyle(Theme.label2)
            }
            if let change {
                Text(change)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(changeOk ? Theme.ok : Theme.danger)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .iosCard()
    }
}
