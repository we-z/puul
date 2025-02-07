
import SwiftUI

@main
struct PuulApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                RatingsView()
                    .environmentObject(StoreVM())
            }
        }
    }
}
