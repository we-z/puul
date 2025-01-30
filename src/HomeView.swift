import SwiftUI

let impactSoft = UIImpactFeedbackGenerator(style: .soft)

struct HomeView: View {
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    
    @State var add_chat_dialog = false
    @State var edit_chat_dialog = false
    @State var model_name = ""
    @State var title = ""
    @State var swiping = false
    @State var allowSwiping = true
    @StateObject var aiChatModel = AIChatModel()
    @StateObject var orientationInfo = OrientationInfo()
    
    @State private var chat_selection: Dictionary<String, String>? = [:]
    @State var after_chat_edit: () -> Void = {}
    
    func close_chat() {
        aiChatModel.stop_predict()
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // MARK: - ChatListView
            ChatListView(
                model_name: $model_name,
                title: $title,
                add_chat_dialog: $add_chat_dialog,
                close_chat: close_chat,
                edit_chat_dialog: $edit_chat_dialog,
                chat_selection: $chat_selection,
                swiping: $swiping,
                allowSwiping: $allowSwiping,
                after_chat_edit: $after_chat_edit
            )
            .environmentObject(aiChatModel)
        } detail: {
            // MARK: - Default to ChatView
            ChatView(
                modelName: $model_name,
                chatSelection: $chat_selection,
                title: $title,
                CloseChat: close_chat,
                AfterChatEdit: $after_chat_edit,
                swiping: $swiping
            )
            .environmentObject(aiChatModel)
        }
        .navigationSplitViewStyle(.balanced)
        .accentColor(.primary)
        .onChange(of: chat_selection) { newValue in
            columnVisibility = .detailOnly
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreVM())
    }
}
