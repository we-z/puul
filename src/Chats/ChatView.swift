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
    @Binding var addChatDialog: Bool
    @Binding var editChatDialog: Bool
    
    @State var chatStyle: String = "None"
    @State private var reloadButtonIcon: String = "arrow.counterclockwise.circle"
    @State private var clearChatButtonIcon: String = "eraser.line.dashed.fill"
    
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
    
    func scrollToBottom(withAnimation: Bool = false) {
        guard autoScroll else { return }
        guard let _ = aiChatModel.messages.last else { return }
        // Example if using scrollProxy:
        // if withAnimation {
        //    withAnimation(.spring()) {
        //        scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        //    }
        // } else {
        //    scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        // }
    }
    
    func reload() async {
        guard let selection = chatSelection else { return }
        aiChatModel.reload_chat(selection)
    }
    
    func hardReloadChat() {
        aiChatModel.hard_reload_chat()
    }
    
    private var scrollDownOverlay: some View {
        Button {
            autoScroll = true
            scrollToBottom()
        } label: {
            Image(systemName: "arrow.down.circle")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .padding([.bottom, .trailing], 15)
                .opacity(0.4)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
            VStack {
                
                // If AI is loading or performing tasks, show progress
                VStack {
                    if aiChatModel.state == .loading ||
                        aiChatModel.state == .ragIndexLoading ||
                        aiChatModel.state == .ragSearch {
                        ProgressView(value: aiChatModel.load_progress)
                            .padding()
                    }
                }
                
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
                                                    inputTextValue = question.replacingOccurrences(of: "\n", with: " ")
                                                    sendMessage()
                                                } label: {
                                                    Text(question)
                                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                                                        .multilineTextAlignment(.leading)
                                                        .padding()
                                                        .background(Color.primary.opacity(0.1))
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
                                    }
                                    Text("").id("latest")
                                }
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
                            ToolbarItemGroup(placement: .topBarLeading) {
                                Button {
                                    isTextFieldFocused = false
                                    switchToChatListTab()
                                } label: {
                                    Image(systemName: "folder")
                                }
                                .buttonStyle(HapticButtonStyle())
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .buttonStyle(HapticButtonStyle())
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .onChange(of: aiChatModel.AI_typing) { _ in
                    scrollToBottom()
                }
                
                // Input bar
                HStack(alignment: .bottom) {
                    TextField(placeholderString, text: $inputTextValue, axis: .vertical)
                        .onSubmit { sendMessage() }
                        .textFieldStyle(.plain)
                        .padding(9)
                        .padding(.horizontal, 9)
                        .background(Color.primary.opacity(0.12))
                        .cornerRadius(24)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...5)
                    
                    Button(action: { sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 33))
                    }
                    .buttonStyle(HapticButtonStyle())
                    .disabled(inputTextValue.isEmpty && !aiChatModel.predicting)
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("Puul")
            
            .onDisappear {
                isTextFieldFocused = false
            }
            .onChange(of: chatSelection) { _ in
                Task {
                    await reload()
                }
            }
    }
    
    private func sendMessage() {
        Task {
            if aiChatModel.predicting {
                aiChatModel.stop_predict()
            } else {
                await aiChatModel.send(
                    message: inputTextValue,
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
            addChatDialog: .constant(false),
            editChatDialog: .constant(false),
            switchToChatListTab: {}
        )
        .environmentObject(AIChatModel())
    }
}
