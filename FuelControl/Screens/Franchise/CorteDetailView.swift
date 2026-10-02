import SwiftUI

struct CorteDetailView: View {
    @State var viewModel: CorteDetailViewModel
    @State private var confirmingClose = false

    var body: some View {
        Form {
            Section {
                Text(viewModel.progress)
                if let closedAt = viewModel.corte?.closedAt {
                    Label("Cerrado · Solo lectura", systemImage: "lock.fill")
                    Text(closedAt, style: .date)
                    Text(closedAt, style: .time)
                }
            }
            ForEach(viewModel.entries) { entry in
                Section("Bomba \(entry.id)") {
                    if viewModel.isClosed {
                        LabeledContent("Combustible", value: entry.fuel.label)
                        LabeledContent("Ventas (gal)", value: entry.sales)
                        LabeledContent("Compras / Recepción (gal)", value: entry.purchases)
                        LabeledContent("Pérdidas o Daños (gal)", value: entry.losses)
                        LabeledContent("Motivo de pérdida", value: entry.reason.rawValue)
                    } else {
                        Picker("Combustible", selection: binding(entry, \.fuel)) {
                            ForEach(FuelType.allCases) { fuel in Text(fuel.label).tag(fuel) }
                        }
                        input("Ventas (gal)", text: binding(entry, \.sales))
                        input("Compras / Recepción (gal)", text: binding(entry, \.purchases))
                        input("Pérdidas o Daños (gal)", text: binding(entry, \.losses))
                        Picker("Motivo de pérdida", selection: binding(entry, \.reason)) {
                            ForEach(LossReason.allCases) { reason in Text(reason.rawValue).tag(reason) }
                        }
                        Button(entry.registered ? "Bomba registrada ✓" : "Registrar bomba \(entry.id)") {
                            viewModel.register(entry.id)
                        }.disabled(entry.registered)
                    }
                }
            }
            Section("Consolidado por combustible y categoría") {
                ForEach(MovementCategory.allCases) { category in
                    DisclosureGroup(category.rawValue) {
                        ForEach(FuelType.allCases) { fuel in
                            LabeledContent(fuel.label, value: viewModel.total(category, fuel: fuel))
                        }
                        LabeledContent("Total general", value: viewModel.total(category)).bold()
                    }
                }
                Text("Los totales de ventas, recepciones y pérdidas se presentan por separado; no se suman movimientos de distinto sentido.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let error = viewModel.error { Text(error).foregroundStyle(Theme.danger) }
            if !viewModel.isClosed {
                Button("Cerrar corte") { confirmingClose = true }
                    .disabled(!viewModel.canClose)
            }
        }
        .navigationTitle(viewModel.corte?.turno.rawValue ?? "Corte")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("El corte cerrado será de solo lectura", isPresented: $confirmingClose, titleVisibility: .visible) {
            Button("Cerrar corte definitivamente") { viewModel.close() }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private func binding<Value>(_ entry: PumpEntry, _ keyPath: WritableKeyPath<PumpEntry, Value>) -> Binding<Value> {
        Binding(get: {
            viewModel.entries.first { $0.id == entry.id }?[keyPath: keyPath] ?? entry[keyPath: keyPath]
        }, set: { value in
            viewModel.update(entry.id) { $0[keyPath: keyPath] = value }
        })
    }
    private func input(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            TextField("0", text: text).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .accessibilityLabel(title)
        }
    }
}
