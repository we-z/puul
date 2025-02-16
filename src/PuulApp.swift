
import SwiftUI

@main
struct PuulApp: App {
    // Read the persisted theme setting.
    @AppStorage("selectedTheme") private var selectedTheme: String = "System"
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(StoreVM())
                    .environmentObject(AppModel())
            }
            // Apply the selected color scheme to the app.
            .preferredColorScheme(
                selectedTheme == "System" ? nil : (selectedTheme == "Dark" ? .dark : .light)
            )
        }
    }
}
