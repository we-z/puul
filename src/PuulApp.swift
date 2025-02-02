
import SwiftUI

@main
struct PuulApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                AssetsQuestionView()
                    .environmentObject(StoreVM())
                    .environmentObject(SurveyViewModel())
            }
        }
    }
}
