import SwiftUI

struct TempView: View {
    @State var add_chat_dialog = false
        @State var edit_chat_dialog = false
        @State var model_name = ""
        @State var title = ""
        
        @StateObject var aiChatModel = AIChatModel()
        @StateObject var orientationInfo = OrientationInfo()
        
        @State private var chat_selection: Dictionary<String, String>?
        @State var after_chat_edit: () -> Void = {}
        
        // 0 = ChatListView, 1 = ChatView
        @State private var selectedTab: Int = 1  // Default to 2nd tab (ChatView)
        
        func close_chat() -> Void {
            aiChatModel.stop_predict()
        }
        
    var body: some View {
        TabView(selection: $selectedTab) {
                        
                        // MARK: - Tab 0: ChatListView
                        ChatListView(
                            tabSelection: $selectedTab,
                            model_name: $model_name,
                            title: $title,
                            add_chat_dialog: $add_chat_dialog,
                            close_chat: close_chat,
                            edit_chat_dialog: $edit_chat_dialog,
                            chat_selection: $chat_selection,
                            after_chat_edit: $after_chat_edit
                        )
                        .environmentObject(aiChatModel)
                        .tag(0)
                        
                        // MARK: - Tab 1: ChatView
                        ChatView(
                            modelName: $model_name,
                            chatSelection: $chat_selection,
                            title: $title,
                            CloseChat: close_chat,
                            AfterChatEdit: $after_chat_edit,
                            addChatDialog: $add_chat_dialog,
                            editChatDialog: $edit_chat_dialog,
                            
                            // Here we implement the closure to switch back to tab 0:
                            switchToChatListTab: {
                                withAnimation {
                                    selectedTab = 0
                                }
                            }
                        )
                        .environmentObject(aiChatModel)
                        .environmentObject(orientationInfo)
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}


struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
