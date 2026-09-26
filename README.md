# FuelControl (iOS / SwiftUI)

Native iOS port of the `FuelControl iOS App Design` Figma Make prototype (React + Tailwind + recharts).
Built with **SwiftUI** and **Swift Charts**, targeting **iOS 17+**.

## Opening the project

This project was generated on Windows (no Xcode/simulator available here to build it), so it has
not been compiled yet. To run it:

1. Copy the `FuelControlApp` folder to a Mac.
2. Open `FuelControl.xcodeproj` in Xcode 16 or later.
3. Select the `FuelControl` scheme and an iPhone simulator (or a Mac with Xcode 16+ supports iOS 17
   simulators out of the box).
4. Build & run (⌘R).

If Xcode reports any build settings it wants to "upgrade" on first open, accept — that's normal for
a hand-authored `project.pbxproj`.

## Structure

- `FuelControl/FuelControlApp.swift` — `@main` app entry point.
- `FuelControl/App/RootView.swift` — switches between the login screen and the two role-based tab
  flows, mirroring the original prototype's `App.tsx` state machine.
- `FuelControl/Models/FuelModels.swift` — Swift types mirroring `data.ts` (`Tank`, `Shift`,
  `Franchise`, `AlertItem`, etc.), with color/label logic moved onto the enums.
- `FuelControl/Models/MockData.swift` — the same sample data as the prototype's `data.ts`, ready to
  be swapped for a real networking layer later.
- `FuelControl/Theme/` — color tokens (`Theme.swift`), the `.ios-card` / primary-button / pill-chip
  styling (`ViewModifiers.swift`), and number formatting (`Formatters.swift`).
- `FuelControl/Components/` — reusable views: `KPICard`, `FuelChip`, `StatusBadge`, `TankGaugeView`,
  `AlertCardView`, `ChartCardView`, `SparklineView`, `SegmentedControlView`.
- `FuelControl/Screens/Auth/LoginView.swift` — login screen with the franchise/general role toggle.
- `FuelControl/Screens/Franchise/` — the franchise manager flow: Inicio, Ventas, Tanques, Turnos,
  shift detail, and the tab container.
- `FuelControl/Screens/General/` — the general manager flow: Resumen, Franquicias (list + map),
  Comparar, Perfil, franchise drill-down, and the tab container.
- `FuelControl/Screens/Shared/AlertasListView.swift` — the alerts screen, reused by both roles with
  different data sets.

## Notes / follow-ups

- All data is static mock data (`MockData.swift`), same as the Figma prototype. Swap it for a real
  API client when one exists.
- Charts use native **Swift Charts** (`import Charts`), which requires **iOS 17** for the donut/pie
  charts (`SectorMark`). If you need to support iOS 16, the payment-method and fuel-mix donut charts
  would need a custom-drawn replacement.
- Navigation uses `NavigationStack` + `navigationDestination(for:)` per tab, so pushing a franchise
  detail and then a shift detail from within it works like the original app's drill-down.
- The bundle identifier is a placeholder (`com.fuelcontrol.app`) — change it in the target's Signing
  & Capabilities tab before running on a device.
