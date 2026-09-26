import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum Theme {
    static let primary = Color(hex: "0B3D91")
    static let accent = Color(hex: "F28C28")
    static let danger = Color(hex: "D93025")
    static let ok = Color(hex: "1E8E3E")

    static let background = Color(hex: "F2F2F7")
    static let card = Color.white
    static let label2 = Color(hex: "636366")
    static let label3 = Color(hex: "C7C7CC")
    static let separator = Color(hex: "C6C6C8")

    static let cardCornerRadius: CGFloat = 12
}
