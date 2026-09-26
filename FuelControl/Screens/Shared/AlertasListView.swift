import SwiftUI

struct AlertasListView: View {
    let alerts: [AlertItem]

    @State private var filter: String = "todas"
    private let categories = ["todas", "críticas", "inventario", "merma", "turnos", "pipas"]

    private var filtered: [AlertItem] {
        alerts.filter { alert in
            switch filter {
            case "todas": return true
            case "críticas": return alert.severity == .critical
            default: return alert.category.rawValue == filter
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Alertas")
                    .font(.system(size: 28, weight: .bold))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                filter = cat
                            } label: {
                                Text(cat.capitalized)
                                    .pillChip(isSelected: filter == cat)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if filtered.isEmpty {
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
                        ForEach(filtered) { alert in
                            AlertCardView(alert: alert)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }
}

#Preview {
    AlertasListView(alerts: MockData.franchiseAlerts)
}
