import SwiftUI

struct KPICard: View {
    let title: String
    let value: String
    var sub: String? = nil
    var change: String? = nil
    var changeOk: Bool = true
    var accent: Color? = nil
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.label2)
                Spacer(minLength: 4)
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(accent ?? Theme.primary)
                }
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(accent ?? .primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            if let sub {
                Text(sub)
                    .font(.caption)
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
