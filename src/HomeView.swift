import SwiftUI

struct HomeView: View {
    
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
        // Single NavigationStack wrapping the entire tab interface:
        NavigationStack {
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
                    // Switch from ChatView -> ChatListView
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
            .tabViewStyle(.page(indexDisplayMode: .never))
            .accentColor(.primary)
            
            // Optional: Manage the .navigationTitle and .toolbar from here
            .navigationTitle(selectedTab == 0 ? "Sessions" : "Puul")
            .toolbar {
                if selectedTab == 0 {
                    // Toolbar for ChatListView
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // e.g. open settings
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                selectedTab = 1
                            }
                        } label: {
                            Image(systemName: "chevron.right.2")
                        }
                    }
                } else {
                    // Toolbar for ChatView
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // Switch to ChatList Tab
                            withAnimation {
                                selectedTab = 0
                            }
                        } label: {
                            Image(systemName: "folder")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // e.g. edit
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
