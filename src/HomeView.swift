//
//  HomeView.swift
//

import SwiftUI

let impactSoft = UIImpactFeedbackGenerator(style: .soft)
let impactMedium = UIImpactFeedbackGenerator(style: .medium)

let sideMenuWidth = deviceWidth * 0.75
let chatViewOffset: CGFloat = -(sideMenuWidth / 2)
let chatListViewOffset: CGFloat = (sideMenuWidth / 2)

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
    
    /// Default chat view position
    @State private var xOffset: CGFloat = chatViewOffset
    
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
            return chatListViewOffset
        case 1:
            // ChatView fully visible => shift left by 0.75 * screenWidth.
            return chatViewOffset
        default:
            return 0
        }
    }
    
    var body: some View {
        
        // The two "pages" side by side:
        //   - ChatListView (0.75 * screen width)
        //   - ChatView (1 * screen width)
        // Total combined width: 1.75 * screenWidth
        HStack(spacing: 0) {
            
            // MARK: - Page 0: ChatListView
            ChatListView(
                xOffset: $xOffset,
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
            .frame(width: deviceWidth * 0.75)
            
            // MARK: - Page 1: ChatView
            ChatView(
                xOffset: $xOffset,
                modelName: $model_name,
                chatSelection: $chat_selection,
                title: $title,
                CloseChat: close_chat,
                AfterChatEdit: $after_chat_edit,
                swiping: $swiping
            )
            
            .environmentObject(aiChatModel)
            .environmentObject(orientationInfo)
            .frame(width: deviceWidth)
            // We'll apply dynamic blur (and overlay) based on how far we've swiped
//                .blur(
//                    radius: {
//                        let offset = xOffset + dragOffset
//                        // Clamp to 0...1 so we don't get a negative ratio or above 1
//                        let ratio = max(0, min(1, -offset / chatListViewOffset))
//                        // Then linearly interpolate the blur from 10 down to ~0.01
//                        return 10 - (9.999 * ratio)
//                    }()
//                )
            .overlay {
                let offset = xOffset + dragOffset
                // Same ratio for overlay fade
                let ratio = -offset / chatListViewOffset
                let blurValue = 10 - 9.99 * ratio
                Color.primary.opacity(blurValue / 90)
                    .ignoresSafeArea()
                    .allowsHitTesting(xOffset == chatListViewOffset)
                    .onTapGesture {
                        if xOffset == chatListViewOffset {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            impactMedium.impactOccurred()
                            xOffset = chatViewOffset
                        }
                    }
            }
        }
        .frame(width: deviceWidth)
        .accentColor(.primary)
        // Offset by currentOffset plus any active drag offset
        .offset(x: xOffset + dragOffset)
        .animation(.linear(duration: 0.1), value: xOffset)
        .onChange(of: xOffset) { _ in
            impactMedium.impactOccurred()
        }
        // DRAG GESTURE
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    let horizontalDistance = abs(value.translation.width)
                    let verticalDistance = abs(value.translation.height)
                    guard horizontalDistance > verticalDistance else { return }
                    let distance = value.translation.width
                    if (xOffset + distance) <= chatListViewOffset && (xOffset + distance) >= chatViewOffset {
                        state = distance
                    }
                }
                .onEnded { value in
                    
                    let horizontalDistance = abs(value.translation.width)
                    let verticalDistance = abs(value.translation.height)
                    guard horizontalDistance > verticalDistance else { return }
                    
                    // Decide if we switch pages based on threshold
                    let threshold = deviceWidth * 0.1
                    let distance = value.translation.width
                                            
                    if (xOffset + distance) <= chatListViewOffset && (xOffset + distance) >= chatViewOffset {
                        xOffset += distance
                    }
                    
                    if distance > threshold {
                        xOffset = chatListViewOffset
                    } else if distance < -threshold {
                        xOffset = chatViewOffset
                    }
//                        impactMedium.impactOccurred()
                }
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreVM())
    }
}
