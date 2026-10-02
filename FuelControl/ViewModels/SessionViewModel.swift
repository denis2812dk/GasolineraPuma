import SwiftUI
import Observation

@Observable final class SessionViewModel {
    private(set) var role: UserRole?
    private(set) var franchiseId = "f1"
    private(set) var accountName = ""
    private(set) var accountEmail = ""

    func login(role: UserRole, franchiseId: String? = nil, name: String, email: String) {
        self.role = role
        if let franchiseId { self.franchiseId = franchiseId }
        accountName = name
        accountEmail = email
    }

    func logout() {
        role = nil
        accountName = ""
        accountEmail = ""
    }
}
