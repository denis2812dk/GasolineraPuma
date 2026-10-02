import SwiftUI

struct FranquiciasView: View {
    @State var viewModel: FranquiciasViewModel
    let onFranchiseSelect: (String) -> Void

    @State private var view = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                SegmentedControlView(options: ["Lista", "Mapa"], selection: $view)
                    .padding(.horizontal, 16)

                if view == 1 {
                    mapView
                } else {
                    listView
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Theme.background)
        .navigationTitle("Franquicias")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - List

    private var listView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.label2)
                TextField("Buscar franquicia o zona...", text: Binding(get: { viewModel.search }, set: { viewModel.search = $0 }))
            }
            .padding(14)
            .background(Theme.subtleFill)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 0) {
                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { i, f in
                    Button {
                        onFranchiseSelect(f.id)
                    } label: {
                        HStack(spacing: 12) {
                            Circle().fill(f.status.color).frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(f.name).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                                Text("\(f.zone) · Merma \(f.merma, specifier: "%.1f")%")
                                    .font(.system(size: 11)).foregroundStyle(Theme.label2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(Format.dollars(f.dailySales)).font(.system(size: 12, weight: .semibold))
                                Text(Format.percent(f.growth))
                                    .font(.system(size: 11))
                                    .foregroundStyle(f.growth >= 0 ? Theme.ok : Theme.danger)
                            }
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Theme.label3)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if i < viewModel.filtered.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .iosCard()
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Map

    private var mapView: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Color(hex: "D9E3F0")
                mapRoads
                ForEach(viewModel.franchises) { f in
                    if let pos = viewModel.mapPositions[f.id] {
                        mapPin(for: f, at: pos)
                    }
                }
                legend
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)

            if let pinFranchise = viewModel.selectedFranchise {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pinFranchise.name).font(.system(size: 15, weight: .bold))
                            Text(pinFranchise.zone).font(.system(size: 12)).foregroundStyle(Theme.label2)
                        }
                        Spacer()
                        StatusBadge(franchiseStatus: pinFranchise.status)
                    }
                    HStack(spacing: 24) {
                        statPair("Ventas hoy", Format.dollars(pinFranchise.dailySales))
                        statPair("Galones", Format.grouped(pinFranchise.dailyGallons))
                        statPair("Merma", pinFranchise.merma.formatted(.number.precision(.fractionLength(1))) + "%")
                    }
                    Button("Ver detalle →") {
                        onFranchiseSelect(pinFranchise.id)
                    }
                    .buttonStyle(.iosPrimary)
                }
                .padding(16)
                .iosCard()
                .padding(.horizontal, 16)
            } else {
                Text("Toca un pin para ver el resumen de la estación")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.label2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }

    private func statPair(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundStyle(Theme.label2)
            Text(value).font(.system(size: 14, weight: .bold))
        }
    }

    private func mapPin(for f: Franchise, at pos: MapPosition) -> some View {
        let isSelected = viewModel.selectedPin == f.id
        return GeometryReader { geo in
            let scaleX = geo.size.width / 393
            let scaleY = geo.size.height / 250
            ZStack {
                if isSelected {
                    Circle().fill(f.status.color.opacity(0.2)).frame(width: 30, height: 30)
                }
                Circle()
                    .fill(f.status.color)
                    .frame(width: isSelected ? 22 : 16, height: isSelected ? 22 : 16)
                    .overlay(Circle().stroke(.white, lineWidth: isSelected ? 3 : 2))
            }
            .position(x: pos.x * scaleX, y: pos.y * scaleY)
            .onTapGesture {
                viewModel.selectedPin = (viewModel.selectedPin == f.id) ? nil : f.id
            }
        }
    }

    private var mapRoads: some View {
        Canvas { context, size in
            let sx = size.width / 393
            let sy = size.height / 250

            var horizontal = Path()
            horizontal.move(to: CGPoint(x: 0, y: 125 * sy))
            horizontal.addLine(to: CGPoint(x: size.width, y: 125 * sy))
            context.stroke(horizontal, with: .color(Color(hex: "B0BEC5")), lineWidth: 6)

            var vertical = Path()
            vertical.move(to: CGPoint(x: 196 * sx, y: 0))
            vertical.addLine(to: CGPoint(x: 196 * sx, y: size.height))
            context.stroke(vertical, with: .color(Color(hex: "B0BEC5")), lineWidth: 6)

            let blocks: [CGRect] = [
                CGRect(x: 80, y: 35, width: 100, height: 60),
                CGRect(x: 215, y: 35, width: 80, height: 60),
                CGRect(x: 210, y: 135, width: 80, height: 50),
                CGRect(x: 80, y: 155, width: 90, height: 55),
            ]
            for block in blocks {
                let rect = CGRect(x: block.minX * sx, y: block.minY * sy, width: block.width * sx, height: block.height * sy)
                context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Color(hex: "C5D5E8").opacity(0.4)))
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 8) {
            legendDot(color: Theme.ok, label: "Óptimo")
            legendDot(color: Theme.accent, label: "Medio")
            legendDot(color: Theme.danger, label: "Crítico")
        }
        .padding(8)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 9, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.white.opacity(0.8))
        .clipShape(Capsule())
    }
}
