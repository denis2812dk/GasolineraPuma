import SwiftUI
import Observation

@Observable final class SessionViewModel {
    private(set) var role: UserRole?
    var franchiseId = "f1"
    func login(_ role: UserRole) { self.role = role }
    func logout() { role = nil }
}
