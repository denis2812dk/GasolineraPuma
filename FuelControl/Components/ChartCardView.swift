import SwiftUI

struct ChartCardView<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let icon {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            } else {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            content
        }
        .padding(14)
        .iosCard()
    }
}
