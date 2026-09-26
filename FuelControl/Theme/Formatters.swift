import Foundation

enum Format {
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 2
        return f
    }()

    static func grouped(_ n: Int) -> String {
        numberFormatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    static func dollars(_ n: Int) -> String {
        "$" + grouped(n)
    }

    static func gallons(_ n: Int) -> String {
        grouped(n) + " gal"
    }

    static func percent(_ n: Double) -> String {
        let prefix = n > 0 ? "+" : ""
        let value = n.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(n))
            : String(format: "%.1f", n)
        return "\(prefix)\(value)%"
    }
}
