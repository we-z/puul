import SwiftUI

let impactSoft = UIImpactFeedbackGenerator(style: .soft)

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
    @State private var selectedTab: Int = 1  // Default to second "page"
    
    /// Current offset of the entire pager (without drag).
    @State private var currentOffset: CGFloat = 0
    
    /// Temporary offset during a drag gesture.
    @GestureState private var dragOffset: CGFloat = 0.0
    
    func close_chat() -> Void {
        aiChatModel.stop_predict()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            
            // A horizontal HStack that contains both "pages"
            HStack(spacing: 0) {
                // MARK: - Page 0: ChatListView
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
                .frame(width: screenWidth)
                
                // MARK: - Page 1: ChatView
                ChatView(
                    modelName: $model_name,
                    chatSelection: $chat_selection,
                    title: $title,
                    CloseChat: close_chat,
                    AfterChatEdit: $after_chat_edit,
                    addChatDialog: $add_chat_dialog,
                    editChatDialog: $edit_chat_dialog,
                    switchToChatListTab: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }
                )
                .environmentObject(aiChatModel)
                .environmentObject(orientationInfo)
                .frame(width: screenWidth)
            }
            // Offset by our "currentOffset" plus whatever drag is happening
            .offset(x: currentOffset + dragOffset)
            // DRAG GESTURE
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        // As we drag, update dragOffset
                        state = value.translation.width
                    }
                    .onEnded { value in
                        // Once the drag ends, decide which page to snap to
                        let threshold = screenWidth * 0.3
                        let distance = value.translation.width
                        var newIndex = selectedTab
                        
                        if distance > threshold {
                            // Swiped right enough to go back
                            newIndex = max(newIndex - 1, 0)
                        } else if distance < -threshold {
                            // Swiped left enough to go forward
                            newIndex = min(newIndex + 1, 1)
                        }
                        
                        if selectedTab == 0 {
                            currentOffset = distance
                        } else {
                            // adjust correct currentOffset here
                            currentOffset = distance - screenWidth
                        }
                        selectedTab = newIndex
                        // Animate from the drag end to the final offset
                        withAnimation {
                            currentOffset = -CGFloat(selectedTab) * screenWidth
                        }
                    }
            )
            // Keep offset in sync any time selectedTab changes programmatically
            .onChange(of: selectedTab) { newIndex in
                impactSoft.impactOccurred()
                withAnimation {
                    currentOffset = -CGFloat(newIndex) * screenWidth
                }
            }
            // Initialize offset on appear
            .onAppear {
                currentOffset = -CGFloat(selectedTab) * screenWidth
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
