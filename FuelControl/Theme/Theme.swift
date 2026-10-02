import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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

/// Design tokens shared by the app and the macOS-only logic test target
/// (`Package.swift`). Anything that needs a UIKit-only adaptive color is
/// guarded behind `canImport(UIKit)` so `swift test` keeps compiling.
/// Puma Energy brand palette: deep green primary, red accent for alerts,
/// white surfaces throughout (the app simulates the Puma El Salvador brand).
enum Theme {
    static let primary = Color(hex: "007142")
    static let primaryLight = Color(hex: "00A862")
    static let accent = Color(hex: "F28C28")
    static let danger = Color(hex: "ED1C24")
    static let ok = Color(hex: "1E8E3E")

    /// Screen background. Plain white in light mode, true black in dark mode.
    static let background: Color = {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color.white
        #endif
    }()

    /// Card/surface background. Also white - cards are separated from the
    /// background with a hairline border and shadow instead of a fill tint.
    static let card: Color = {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color.white
        #endif
    }()

    /// A subtle adaptive fill for search bars, unselected chips, etc.
    static let subtleFill: Color = {
        #if canImport(UIKit)
        Color(uiColor: .tertiarySystemFill)
        #else
        Color(hex: "787880").opacity(0.12)
        #endif
    }()

    static let label2: Color = {
        #if canImport(UIKit)
        Color(uiColor: .secondaryLabel)
        #else
        Color(hex: "636366")
        #endif
    }()

    static let label3: Color = {
        #if canImport(UIKit)
        Color(uiColor: .tertiaryLabel)
        #else
        Color(hex: "C7C7CC")
        #endif
    }()

    static let separator: Color = {
        #if canImport(UIKit)
        Color(uiColor: .separator)
        #else
        Color(hex: "C6C6C8")
        #endif
    }()

    static let cardCornerRadius: CGFloat = 16
}
