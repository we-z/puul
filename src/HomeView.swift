//
//  HomeView.swift
//

import SwiftUI

let impactSoft = UIImpactFeedbackGenerator(style: .soft)

struct HomeView: View {
    
    @State var add_chat_dialog = false
    @State var edit_chat_dialog = false
    @State var model_name = ""
    @State var title = ""
    @State var swiping = false
    @State var allowSwiping = true
    @StateObject var aiChatModel = AIChatModel()
    @StateObject var orientationInfo = OrientationInfo()
    
    @State private var chat_selection: Dictionary<String, String>?
    @State var after_chat_edit: () -> Void = {}
    
    // 0 = ChatListView, 1 = ChatView
    @State private var selectedTab: Int = 1  // Default to second "page"
    
    /// Current offset of the entire pager (without drag).
    @State private var currentOffset: CGFloat = 0
    
    /// Temporary offset during a drag gesture.
    @GestureState private var dragOffset: CGFloat = 0
    
    func close_chat() {
        aiChatModel.stop_predict()
    }
    
    /// Returns the "base" offset for each tab (i.e., where the view should snap to when fully at that tab).
    private func offsetForTab(_ tab: Int, screenWidth: CGFloat) -> CGFloat {
        switch tab {
        case 0:
            // ChatListView fully visible.
            return 0
        case 1:
            // ChatView fully visible => shift left by 0.75 * screenWidth.
            return -0.75 * screenWidth
        default:
            return 0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            
            // The two "pages" side by side:
            //   - ChatListView (0.75 * screen width)
            //   - ChatView (1 * screen width)
            // Total combined width: 1.75 * screenWidth
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
                    allowSwiping: $allowSwiping,
                    after_chat_edit: $after_chat_edit
                )
                .environmentObject(aiChatModel)
                .frame(width: screenWidth * 0.75)
                
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
                // We'll apply dynamic blur (and overlay) based on how far we've swiped
                .blur(
                    radius: {
                        let offset = currentOffset + dragOffset
                        // Our valid range of offset: [0 ... -0.75 * screenWidth]
                        // Map that to a ratio [0 ... 1]
                        let maxOffset = -0.75 * screenWidth
                        // Clamp to 0...1 so we don't get a negative ratio or above 1
                        let ratio = max(0, min(1, -offset / (0.75 * screenWidth)))
                        // Then linearly interpolate the blur from 10 down to ~0.01
                        return 10 - (9.99 * ratio)
                    }()
                )
                .overlay {
                    let offset = currentOffset + dragOffset
                    // Same ratio for overlay fade
                    let ratio = max(0, min(1, -offset / (0.75 * screenWidth)))
                    let blurValue = 10 - 9.99 * ratio
                    Color.primary.opacity(blurValue / 100)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .accentColor(.primary)
            // Offset by currentOffset plus any active drag offset
            .offset(x: currentOffset + dragOffset)
            // DRAG GESTURE
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        guard allowSwiping else { return }
                        
                        let horizontalDistance = abs(value.translation.width)
                        let verticalDistance = abs(value.translation.height)
                        
                        // Only track this gesture if horizontal movement exceeds vertical
                        guard horizontalDistance > verticalDistance else { return }
                        
                        // We'll let the user drag, but we can optionally limit how far they can pull
                        let translation = value.translation.width
                        
                        // If we are at tab 0 and swiping right (translation > 0),
                        // or at tab 1 and swiping left (translation < 0),
                        // we might want to apply a reduced drag once we go "past" the edge.
                        
                        let isAtLeftEdge = (selectedTab == 0 && translation > 0)
                        let isAtRightEdge = (selectedTab == 1 && translation < 0)
                        
                        if isAtLeftEdge || isAtRightEdge {
                            // Scale the drag offset if going beyond edges
//                            state = translation / 3
                        } else {
                            state = translation
                        }
                        
                        // Dismiss the keyboard when swiping
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .onEnded { value in
                        guard allowSwiping else { return }
                        
                        let horizontalDistance = abs(value.translation.width)
                        let verticalDistance = abs(value.translation.height)
                        guard horizontalDistance > verticalDistance else { return }
                        
                        // Decide if we switch pages based on threshold
                        let threshold = screenWidth * 0.1
                        let distance = value.translation.width
                        
                        var newIndex = selectedTab
                        
                        if distance > threshold {
                            newIndex = max(newIndex - 1, 0)
                        } else if distance < -threshold {
                            newIndex = min(newIndex + 1, 1)
                        }
                        
                        if newIndex == selectedTab {
                            if selectedTab == 0 && distance > 0 {
                                // Already on left page
                            } else if selectedTab == 1 && distance < 0 {
                                // Already on right page
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
                                currentOffset = distance - screenWidth * 0.75
                            }
                        }
                        
                        // Animate to the final offset
                        withAnimation(.spring()) {
                            currentOffset = offsetForTab(newIndex, screenWidth: screenWidth)
                        }
                        
                        // Update the selected tab
                        selectedTab = newIndex
                    }
            )
            // Keep offset in sync when the tab changes programmatically
            .onChange(of: selectedTab) { newIndex in
                impactSoft.impactOccurred()
                withAnimation(.spring()) {
                    currentOffset = offsetForTab(newIndex, screenWidth: screenWidth)
                }
            }
            // Initialize offset on appear
            .onAppear {
                currentOffset = offsetForTab(selectedTab, screenWidth: screenWidth)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreVM())
    }
}
