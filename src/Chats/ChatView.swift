//
//  ChatView.swift
//
//  Created by Guinmoon
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var aiChatModel: AIChatModel
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    @State var placeholderString: String = "Message"
    @State private var inputText: String = "Message"
    
    @Binding var modelName: String
    @Binding var chatSelection: Dictionary<String, String>?
    @Binding var title: String
    var CloseChat: () -> Void
    @Binding var AfterChatEdit: () -> Void
    @Binding var swiping: Bool
    
    @State var chatStyle: String = "DocC"
    @State private var reloadButtonIcon: String = "arrow.counterclockwise.circle"
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var scrollTarget: Int?
    @State private var toggleEditChat = false
    @State private var clearChatAlert = false
    
    @State private var autoScroll = true
    @State private var enableRAG = false
    @State private var inputTextValue: String = ""
    @State private var isAttachmentPopoverPresented: Bool = false
    @State private var selectedImageData: Data? = nil
    @State private var imgCachePath: String? = nil
    
    @FocusState var isTextFieldFocused: Bool
    
    @Namespace var bottomID
    
    let financialQuestions = [
        "How can I improve\nmy credit score?",
        "Should I refinance\nmy mortgage?",
        "How much should I\nsave for retirement?",
        "What should I do\nto reduce my debt?",
        "Is my investment\nportfolio balanced?",
        "How much should I save\nfor my child's education?",
        "Am I on track to\nmeet my financial goals?",
        "What are the best\ntax-saving strategies for me?",
        "How much should I be\nsaving each month?"
    ]
    
    /// Closure that sets the tabSelection to 0 (ChatListView) with animation.
    var switchToChatListTab: () -> Void
    
    func scrollToBottom(with_animation:Bool = false) {
        var scroll_bug = true
#if os(macOS)
        scroll_bug = false
#else
        if #available(iOS 16.4, *){
            scroll_bug = false
        }
#endif
        if scroll_bug {
            return
        }
        if !autoScroll {
            return
        }
        let last_msg = aiChatModel.messages.last // try to fixscrolling and  specialized Array._checkSubscript(_:wasNativeTypeChecked:)
        if last_msg != nil && last_msg?.id != nil && scrollProxy != nil{
            if with_animation{
                withAnimation {
                    //                    scrollProxy?.scrollTo(last_msg?.id, anchor: .bottom)
                    scrollProxy?.scrollTo("latest")
                }
            }else{
                //                scrollProxy?.scrollTo(last_msg?.id, anchor: .bottom)
                scrollProxy?.scrollTo("latest")
            }
        }
        
    }
    
    func reload() async {
        guard let selection = chatSelection else { return }
        aiChatModel.reload_chat(selection)
    }
    
    func hardReloadChat() {
        aiChatModel.hard_reload_chat()
    }
    
    func newChat() {
        // 1) Save the current chat
        aiChatModel.save_chat_history_and_state()
        
        // 2) Clear out in-memory chat data for a new empty session
        aiChatModel.chat = nil
        
        aiChatModel.chat_name = ""
        aiChatModel.model_name = ""
        aiChatModel.Title = ""
        aiChatModel.messages.removeAll()
        // 3) Clear local UI bindings
        chatSelection = nil
        title = ""
        inputTextValue = ""
        isTextFieldFocused = true
    }
    
    private var scrollDownOverlay: some View {
        Button {
            autoScroll = true
            scrollToBottom()
        } label: {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .foregroundColor(.primary)
                .frame(width: 25, height: 25)
                .padding([.bottom], 15)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
            VStack {
                ScrollViewReader { scrollView in
                    NavigationStack {
                        VStack {
                            if aiChatModel.messages.isEmpty {
                                // Prompt area for new user
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Ask your AI financial advisor any question")
                                        Spacer()
                                        VStack {
                                            Spacer()
                                                .frame(maxHeight: 120)
                                            Image(systemName: "arrow.turn.right.down")
                                        }
                                    }
                                    .padding(.vertical)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.1))
                                    .padding(.horizontal, 35)
                                    
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 10) {
                                            ForEach(financialQuestions, id: \.self) { question in
                                                Button {
                                                    sendMessage(message: question.replacingOccurrences(of: "\n", with: " "))
                                                } label: {
                                                    Text(question)
                                                        .colorInvert()
                                                        .font(.system(size: 15))
                                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                                                        .multilineTextAlignment(.leading)
                                                        .padding()
                                                        .background(Color.primary)
                                                        .cornerRadius(20)
                                                        .padding(.vertical, 5)
                                                }
                                                .buttonStyle(HapticButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .scrollIndicators(.hidden)
                                    .padding(.bottom)
                                    
                                }
                                .background(.primary.opacity(0.001))
                                .onTapGesture {
                                    isTextFieldFocused.toggle()
                                }
                            } else {
                                ScrollView {
                                    ForEach(aiChatModel.messages, id: \.id) { message in
                                        MessageView(message: message, chatStyle: $chatStyle, status: nil)
                                            .id(message.id)
                                            .padding()
                                            .contextMenu {
                                                Button {
                                                    UIPasteboard.general.string = message.text
                                                } label: {
                                                    HStack {
                                                        Text("Copy")
                                                        Spacer()
                                                        Image(systemName: "square.on.square")
                                                    }
                                                }
                                            }
                                    }
                                    Text("").id("latest")
                                }
                                .simultaneousGesture(
                                   DragGesture()
                                    .onEnded { _ in
                                        autoScroll = false
                                   }
                                )
                                .scrollIndicators(.hidden)
                                .onTapGesture {
                                    isTextFieldFocused = false
                                }
                                
                                .onAppear {
                                    scrollProxy = scrollView
                                    scrollToBottom()
                                }
                            }
                        }
                        .navigationTitle("Puul")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    isTextFieldFocused = false
                                    switchToChatListTab()
                                } label: {
                                    Image(systemName: "sidebar.left")
                                }
                                .buttonStyle(HapticButtonStyle())
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    if !aiChatModel.messages.isEmpty {
                                        withAnimation(.easeInOut) {
                                            newChat()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .disabled(aiChatModel.messages.isEmpty)
                                .opacity(aiChatModel.messages.isEmpty ? 0.3 : 1)
                                .buttonStyle(HapticButtonStyle())
                            }
                            
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .onChange(of: aiChatModel.AI_typing) { _ in
                    if !autoScroll {
                        scrollToBottom()
                    }
                }
                
                // Input bar
                HStack(alignment: .bottom) {
                    TextField(placeholderString, text: $inputTextValue, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 17))
                        .padding(9)
                        .padding(.horizontal, 9)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(24)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...5)
                    
                    Button(action: { sendMessage(message: inputTextValue) }) {
                        Image(systemName: aiChatModel.predicting ? "stop.circle.fill" : "arrow.up.circle.fill")
                            .font(.system(size: 33))
                    }
                    .buttonStyle(HapticButtonStyle())
                    .disabled(inputTextValue.isEmpty && !aiChatModel.predicting)
                }
                .padding(.horizontal)
                .padding(.top, 3)
                .padding(.bottom, 9)
                .onTapGesture {
                    isTextFieldFocused = true
                }
                .onChange(of: isTextFieldFocused) { _ in
                    impactSoft.impactOccurred()
                }
            }
            .onDisappear {
                isTextFieldFocused = false
            }
            .onChange(of: chatSelection) { _ in
                Task {
                    await reload()
                }
            }
            .onChange(of: swiping) { _ in
                isTextFieldFocused = false
            }
    }
    
    private func sendMessage(message: String) {
        self.autoScroll = true
        Task {
            if aiChatModel.predicting {
                aiChatModel.stop_predict()
            } else {
                await aiChatModel.send(
                    message: message,
                    attachment: imgCachePath,
                    attachment_type: (imgCachePath != nil ? "img" : nil),
                    useRag: enableRAG
                )
                inputTextValue = ""
                imgCachePath = nil
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(
            modelName: .constant(""),
            chatSelection: .constant([:]),
            title: .constant("Title"),
            CloseChat: {},
            AfterChatEdit: .constant({}),
            swiping: .constant(false),
            switchToChatListTab: {}
        )
        .environmentObject(AIChatModel())
    }
}
