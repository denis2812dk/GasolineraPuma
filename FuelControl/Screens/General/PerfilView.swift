import SwiftUI

struct PerfilView: View {
    let name: String
    let email: String
    let onLogout: () -> Void

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    @State private var notifAlerts = true
    @State private var notifInventory = true
    @State private var notifCortes = false
    @State private var notifPipas = true

    private struct NotifRow: Identifiable {
        let id: String
        let label: String
        let sub: String
        let binding: Binding<Bool>
    }

    private var notifRows: [NotifRow] {
        [
            NotifRow(id: "alerts", label: "Alertas críticas", sub: "Inventario, merma, equipos", binding: $notifAlerts),
            NotifRow(id: "inventory", label: "Inventario", sub: "Niveles de tanque y recepciones", binding: $notifInventory),
            NotifRow(id: "cortes", label: "Cortes", sub: "Registro y cierre de cortes", binding: $notifCortes),
            NotifRow(id: "pipas", label: "Pipas", sub: "Diferencias en recepciones", binding: $notifPipas),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 64, height: 64)
                        .overlay(Text(initials).font(.system(size: 24, weight: .bold)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name).font(.headline)
                        Text(email).font(.caption).foregroundStyle(Theme.label2)
                        Text("Gerente General")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Theme.primary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .iosCard()

                Text("NOTIFICACIONES")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.label2)

                VStack(spacing: 0) {
                    ForEach(Array(notifRows.enumerated()), id: \.element.id) { i, row in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.label).font(.subheadline.weight(.semibold))
                                Text(row.sub).font(.caption).foregroundStyle(Theme.label2)
                            }
                            Spacer()
                            Toggle("", isOn: row.binding)
                                .labelsHidden()
                                .tint(Theme.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        if i < notifRows.count - 1 { Divider().padding(.leading, 16) }
                    }
                }
                .iosCard()

                Text("CUENTA")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.label2)

                VStack(spacing: 0) {
                    ForEach(Array(accountRows.enumerated()), id: \.offset) { i, item in
                        Button {} label: {
                            HStack {
                                Label(item.0, systemImage: item.1).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.label3)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if i < accountRows.count - 1 { Divider().padding(.leading, 16) }
                    }
                }
                .iosCard()

                Button("Cerrar sesión", role: .destructive) {
                    onLogout()
                }
                .buttonStyle(.iosPrimary(background: Theme.danger))

                Text("FuelControl v2.1.0 · © 2026 FuelControl Inc.")
                    .font(.caption)
                    .foregroundStyle(Theme.label2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
    }

    private let accountRows: [(String, String)] = [
        ("Cambiar contraseña", "lock.fill"),
        ("Configuración de red", "wifi"),
        ("Soporte técnico", "questionmark.circle.fill"),
    ]
}

#Preview {
    PerfilView(name: "Alejandro Rivas", email: "alejandro@fuelcontrol.com", onLogout: {})
}
