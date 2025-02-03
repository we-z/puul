
import SwiftUI

@main
struct PuulApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                SurveyView()
                    .environmentObject(StoreVM())
                    .environmentObject(AIChatModel())
            }
        }
    }
}
