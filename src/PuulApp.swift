
import SwiftUI

@main
struct PuulApp: App {
    @StateObject public var appModel: AppModel = .init()
    @StateObject var plaidModel: PlaidModel = .init()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .preferredColorScheme(appModel.isLightMode ? .light : .dark)
                    .buttonStyle(HapticButtonStyle())
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .inactive {
                            print("Inactive")
                        } else if newPhase == .active {
                            print("Active")
                            plaidModel.updateAccounts()
                        } else if newPhase == .background {
                            print("Background")
                        }
                    }
            }
            .environmentObject(StoreVM())
            .environmentObject(appModel)
            .environmentObject(plaidModel)
            .accentColor(.primary)
        }
    }
}
