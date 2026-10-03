import SwiftUI

struct AdministracionView: View {
    @State var viewModel: AdministracionViewModel
    var body: some View {
        @Bindable var model = viewModel
        Form {
            Section("Cuentas de prueba") {
                LabeledContent("Gerente General", value: viewModel.general.generalAccount.email)
                LabeledContent("Contraseña", value: viewModel.general.generalAccount.password)
                Text("Las cuentas de Gerente de Sucursal creadas aquí inician sesión con su propio correo y contraseña, una vez vinculadas a una estación.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Precios de combustible (USD/galón)") {
                priceRow(.regular, text: $model.regularPriceText)
                priceRow(.superFuel, text: $model.superPriceText)
                priceRow(.diesel, text: $model.dieselPriceText)
                Button("Actualizar precios") { viewModel.updatePrices() }
            }
            Section("Registrar nueva estación de servicio") {
                TextField("Nombre de estación", text: $model.stationName)
                TextField("Zona", text: $model.zone)
                Button("Registrar estación") { viewModel.addStation() }
            }
            Section("Alta de gerente de sucursal") {
                TextField("Nombre completo", text: $model.managerName)
                TextField("Correo electrónico", text: $model.email)
                    .keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                SecureField("Contraseña (mín. 4 caracteres)", text: $model.password)
                LabeledContent("Rol", value: "Gerente de sucursal")
                Button("Crear gerente") { viewModel.addManager() }
                Text("Con esta contraseña y el correo, el gerente podrá iniciar sesión una vez vinculado a una sucursal.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Vincular gerente a sucursal") {
                Picker("Gerente", selection: $model.selectedManager) {
                    Text("Seleccionar").tag(Optional<UUID>.none)
                    ForEach(viewModel.general.managers) { manager in
                        Text(manager.name + " · " + manager.email).tag(Optional(manager.id))
                    }
                }
                Picker("Sucursal", selection: $model.selectedStation) {
                    Text("Seleccionar").tag("")
                    ForEach(viewModel.general.franchises) { station in Text(station.name).tag(station.id) }
                }
                Button("Guardar vínculo") { viewModel.link() }
                Text("Cada sucursal tiene un gerente asignado. Guardar reemplaza su vínculo anterior.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let message = viewModel.message {
                Section("Resultado") { Text(message).accessibilityAddTraits(.updatesFrequently) }
            }
            Section("Gerentes registrados") {
                ForEach(viewModel.general.managers) { manager in
                    VStack(alignment: .leading) {
                        Text(manager.name)
                        Text(manager.email).font(.caption)
                        Text("Contraseña: \(manager.password)").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Section("Asignaciones") {
                ForEach(viewModel.general.franchises) { station in
                    LabeledContent(station.name, value: viewModel.general.manager(for: station.id)?.name ?? "Sin gerente")
                }
            }
            Section("Datos") {
                Text("Los cambios se guardan automáticamente en el dispositivo y persisten al cerrar la app.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Restablecer datos de demostración", role: .destructive) {
                    viewModel.general.resetToDemoData()
                }
            }
        }.navigationTitle("Administración")
    }

    private func priceRow(_ fuel: FuelType, text: Binding<String>) -> some View {
        HStack {
            FuelChip(type: fuel)
            Spacer()
            Text(viewModel.general.price(fuel).formatted(.currency(code: "USD")))
                .foregroundStyle(.secondary)
            TextField("Nuevo", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
        }
    }
}
