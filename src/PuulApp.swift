
import SwiftUI

@main
struct PuulApp: App {
    @StateObject public var appModel: AppModel = .init()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
            }
        }
    }
}
