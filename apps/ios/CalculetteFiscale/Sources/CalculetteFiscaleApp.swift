import SwiftUI

@main
struct CalculetteFiscaleApp: App {
    @State private var entitlementStore = EntitlementStore()

    init() {
        #if DEBUG
        if ScreenshotScenario.current?.isPro == true {
            UserDefaults.standard.set(true, forKey: EntitlementStore.proEntitlementCacheKey)
            _entitlementStore = State(
                initialValue: EntitlementStore(
                    service: PreviewStoreKitService(),
                    defaults: .standard
                )
            )
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            CalculatorShellView(screenshotScenario: ScreenshotScenario.current)
                .environment(entitlementStore)
                .task {
                    if ScreenshotScenario.current == nil {
                        entitlementStore.start()
                    }
                }
        }
    }
}
