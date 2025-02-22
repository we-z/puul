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
    
    @Binding var xOffset: CGFloat
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
    @StateObject public var model: AppModel = AppModel()
    
    // New state variables for the sheet
    @State private var isShowingTextSheet: Bool = false
    @State private var selectedMessageText: String = ""
    @State private var selectedTextStyle: UIFont.TextStyle = .body
    
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
        
    func scrollToBottom(with_animation: Bool = false) {
        let last_msg = aiChatModel.messages.last // try to fixscrolling and specialized Array._checkSubscript(_:wasNativeTypeChecked:)
        if last_msg != nil && last_msg?.id != nil && scrollProxy != nil {
            if with_animation {
                withAnimation {
                    scrollProxy?.scrollTo("latest")
                }
            } else {
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
                                    Text("Ask your AI wealth advisor any question")
                                    Spacer()
                                    VStack {
                                        Spacer()
                                            .frame(maxHeight: 120)
                                        Image(systemName: "arrow.turn.right.down")
                                    }
                                }
                                .padding(.vertical)
                                .font(.system(size: UIScreen.main.bounds.width * 0.11))
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
                                        .frame(width: deviceWidth)
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
                                            Button {
                                                // Set the selected text and show the sheet
                                                selectedMessageText = message.text
                                                isShowingTextSheet = true
                                            } label: {
                                                HStack {
                                                    Text("Select Text")
                                                    Spacer()
                                                    Image(systemName: "text.cursor")
                                                }
                                            }
                                        }
                                }
                                Text("").id("latest")
                            }
                            .simultaneousGesture(
                                DragGesture()
                                    .onEnded { _ in
                                        self.autoScroll = false
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
                                xOffset = chatListViewOffset
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
                if autoScroll {
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
                if model.hapticModeOn {
                    impactMedium.impactOccurred()
                }
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
        // Sheet presenting the selected message text using TextView
        .sheet(isPresented: $isShowingTextSheet) {
            NavigationView {
                VStack {
                    TextView(text: $selectedMessageText, textStyle: $selectedTextStyle)
                }
                .navigationTitle("Select Text")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isShowingTextSheet = false
                        }
                        .accentColor(.primary)
                    }
                }
            }
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
            xOffset: .constant(1),
            modelName: .constant(""),
            chatSelection: .constant([:]),
            title: .constant("Title"),
            CloseChat: {},
            AfterChatEdit: .constant({}),
            swiping: .constant(false)
        )
        .environmentObject(AIChatModel())
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.isEditable = false
        textView.isSelectable = true
        textView.text = text
        // Add padding to the text view
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
        // Ensure the padding remains updated
        uiView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}
