//
//  DemoView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 2/2/25.
//

import SwiftUI

struct DemoView: View {
    @EnvironmentObject var aiChatModel: AIChatModel
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    @State var placeholderString: String = "Message"
    @State private var inputText: String = "Message"
    
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
        
    func scrollToBottom(with_animation:Bool = false) {
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
    
    func hardReloadChat() {
        aiChatModel.hard_reload_chat()
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
//                    NavigationStack {
                    VStack {
                        if aiChatModel.messages.isEmpty {
                            // Prompt area for new user
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Try asking Puul an example question off-line")
                                    Spacer()
                                    VStack {
                                        Spacer()
                                            .frame(maxHeight: 120)
                                        Image(systemName: "arrow.turn.right.down")
                                    }
                                }
                                .padding(.vertical)
                                .font(.system(size: UIScreen.main.bounds.width * 0.1))
                                .padding(.horizontal, 30)
                                
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
                            NavigationStack {
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
                                .navigationTitle("Puul")
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
            
        }
        .onDisappear {
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

#Preview {
    DemoView()
        .environmentObject(AIChatModel())
}
