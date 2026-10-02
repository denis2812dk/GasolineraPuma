import SwiftUI

struct SegmentedControlView: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(options.indices, id: \.self) { i in
                Text(options[i]).tag(i)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}
