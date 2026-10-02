import SwiftUI

struct FranchiseDetailView: View {
    @State var viewModel: FranchiseDetailViewModel
    var body: some View {
        Group {
            if let franchise = viewModel.franchise, let sucursal = viewModel.sucursal {
                VStack(spacing: 8) {
                    Text(franchise.zone + " · " + viewModel.managerName)
                        .font(.caption).foregroundStyle(Theme.label2)
                    FranchiseTabView(general: viewModel.general, sucursal: sucursal)
                }
                .navigationTitle(franchise.name)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Estación no disponible", systemImage: "building.2")
            }
        }
    }
}
