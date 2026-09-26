import SwiftUI

struct PerfilView: View {
    let onLogout: () -> Void

    @State private var notifAlerts = true
    @State private var notifInventory = true
    @State private var notifTurnos = false
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
            NotifRow(id: "turnos", label: "Turnos", sub: "Aperturas y cierres de turno", binding: $notifTurnos),
            NotifRow(id: "pipas", label: "Pipas", sub: "Diferencias en recepciones", binding: $notifPipas),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Perfil").font(.system(size: 28, weight: .bold))

                HStack(spacing: 16) {
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: 64, height: 64)
                        .overlay(Text("AR").font(.system(size: 24, weight: .bold)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alejandro Rivas").font(.system(size: 17, weight: .bold))
                        Text("alejandro@fuelcontrol.com").font(.system(size: 13)).foregroundStyle(Theme.label2)
                        Text("Gerente General")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color(hex: "EDF2FF"))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .iosCard()

                Text("NOTIFICACIONES")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.label2)

                VStack(spacing: 0) {
                    ForEach(Array(notifRows.enumerated()), id: \.element.id) { i, row in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.label).font(.system(size: 13, weight: .semibold))
                                Text(row.sub).font(.system(size: 11)).foregroundStyle(Theme.label2)
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.label2)

                VStack(spacing: 0) {
                    ForEach(Array(["Cambiar contraseña", "Configuración de red", "Soporte técnico"].enumerated()), id: \.offset) { i, item in
                        Button {} label: {
                            HStack {
                                Text(item).font(.system(size: 13)).foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.black.opacity(0.3))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if i < 2 { Divider().padding(.leading, 16) }
                    }
                }
                .iosCard()

                Button("Cerrar sesión", role: .destructive) {
                    onLogout()
                }
                .buttonStyle(.iosPrimary(background: Theme.danger))

                Text("FuelControl v2.1.0 · © 2026 FuelControl Inc.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.label2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
    }
}

#Preview {
    PerfilView(onLogout: {})
}
