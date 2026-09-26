import SwiftUI

/// Mirrors the custom `.seg-control` pill segmented control from the original design.
struct SegmentedControlView: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { i in
                Button {
                    selection = i
                } label: {
                    Text(options[i])
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selection == i ? .black : .black.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(selection == i ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .shadow(color: .black.opacity(selection == i ? 0.12 : 0), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Color(hex: "787880").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}
