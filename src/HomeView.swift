import SwiftUI

let impactSoft = UIImpactFeedbackGenerator(style: .soft)

struct HomeView: View {
    
    @State var add_chat_dialog = false
    @State var edit_chat_dialog = false
    @State var model_name = ""
    @State var title = ""
    @State var swiping = false
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
                    swiping: $swiping,
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
                    swiping: $swiping,
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
            .accentColor(.primary)
            // Offset by currentOffset plus any active drag offset
            .offset(x: currentOffset + dragOffset)
            // DRAG GESTURE
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        let translation = value.translation.width
                        // Scale the drag offset if swiping beyond the edges
                        if (selectedTab == 0 && translation > 0) ||
                           (selectedTab == 1 && translation < 0) {
                            state = translation / 3
                        } else {
                            state = translation
                        }
                        swiping.toggle()
                    }
                    .onEnded { value in
                        let threshold = screenWidth * 0.1
                        let distance = value.translation.width
                        
                        var newIndex = selectedTab
                        // Decide whether to switch pages
                        if distance > threshold {
                            newIndex = max(newIndex - 1, 0)
                        } else if distance < -threshold {
                            newIndex = min(newIndex + 1, 1)
                        }
                        
                        // If we stay on the same page but went beyond an edge, apply the 1/3 offset
                        if newIndex == selectedTab {
                            if selectedTab == 0 && distance > 0 {
                                // Already on left page, swiped further left
                                currentOffset = distance / 3
                            } else if selectedTab == 1 && distance < 0 {
                                // Already on right page, swiped further right
                                currentOffset = distance / 3 - screenWidth
                            } else {
                                // Normal offset if not beyond edges
                                currentOffset = (selectedTab == 0)
                                    ? distance
                                    : distance - screenWidth
                            }
                        } else {
                            // If we’re actually switching pages, do the normal offset
                            if selectedTab == 0 {
                                currentOffset = distance
                            } else {
                                currentOffset = distance - screenWidth
                            }
                        }
                        
                        // Update the selected tab
                        selectedTab = newIndex
                        
                        // Animate to the final offset
                        withAnimation(.spring()) {
                            currentOffset = -CGFloat(selectedTab) * screenWidth
                        }
                    }
            )
            // Keep offset in sync when the tab changes programmatically
            .onChange(of: selectedTab) { newIndex in
                impactSoft.impactOccurred()
                withAnimation(.spring()) {
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
