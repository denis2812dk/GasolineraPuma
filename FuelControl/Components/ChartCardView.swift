import SwiftUI

struct ChartCardView<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black)
            content
        }
        .padding(12)
        .iosCard()
    }
}
