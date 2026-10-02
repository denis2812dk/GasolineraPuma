import SwiftUI

struct AlertasListView: View {
    @State var viewModel: AlertsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            Button {
                                viewModel.filter = cat
                            } label: {
                                Text(cat.capitalized)
                                    .pillChip(isSelected: viewModel.filter == cat)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if viewModel.filtered.isEmpty {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Theme.background).frame(width: 64, height: 64)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.ok)
                        }
                        Text("Sin alertas").font(.system(size: 17, weight: .semibold))
                        Text("Todo está en orden en esta categoría.")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.label2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filtered) { alert in
                            AlertCardView(alert: alert)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
        .navigationTitle("Alertas")
        .navigationBarTitleDisplayMode(.large)
    }
}
