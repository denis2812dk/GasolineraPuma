import SwiftUI

struct KPICard: View {
    let title: String
    let value: String
    var sub: String? = nil
    var change: String? = nil
    var changeOk: Bool = true
    var accent: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.label2)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(accent ?? .primary)
            if let sub {
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.label2)
            }
            if let change {
                Text(change)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(changeOk ? Theme.ok : Theme.danger)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .iosCard()
    }
}
