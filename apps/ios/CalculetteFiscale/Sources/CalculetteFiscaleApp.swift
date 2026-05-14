import SwiftUI

@main
struct CalculetteFiscaleApp: App {
    @State private var entitlementStore = EntitlementStore()

    var body: some Scene {
        WindowGroup {
            CalculatorShellView()
                .environment(entitlementStore)
                .task {
                    entitlementStore.start()
                }
        }
    }
}
