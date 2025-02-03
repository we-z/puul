
import SwiftUI

@main
struct PuulApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                DemoView()
                    .environmentObject(StoreVM())
                    .environmentObject(AIChatModel())
            }
        }
    }
}
