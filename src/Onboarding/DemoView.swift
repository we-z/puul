//
//  DemoView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 2/2/25.
//

import SwiftUI
import Network

struct DemoView: View {
    @EnvironmentObject var aiChatModel: AIChatModel
        
    @State var chatStyle: String = "DocC"
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var airplaneAlert = false
    
    @State private var autoScroll = true
    @State private var enableRAG = false
    @State private var imgCachePath: String? = nil
    @State private var chevronOffset: CGFloat = 0.0
    @State private var done: Bool = false
    
    @State var placeholderString: String = "Message"
    @State private var inputText: String = "Message"
    @State private var inputTextValue: String = ""
    
    @FocusState var isTextFieldFocused: Bool
        
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
                VStack {
                    if aiChatModel.messages.isEmpty {
                        // Prompt area for new user
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "airplane.circle.fill")
                                Text("Turn on Airplane Mode")
                                    .bold()
                                Image(systemName: "chevron.down")
                                    .offset(y: chevronOffset)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: chevronOffset)
                                    .onAppear {
                                        chevronOffset = 12
                                    }
                                    
                            }
                            .padding(.vertical)
                            .font(.system(size: 24))
                            .padding(.horizontal, 30)
                            
                            Spacer()
                            HStack {
                                Text("Try Puul off-line with an example question ")
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
            .animation(.default, value: aiChatModel.messages.isEmpty)
            if !aiChatModel.messages.isEmpty {
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation(.easeInOut) {
                            done = true
                        }
                    }
                    let monitor = NWPathMonitor()
                    monitor.pathUpdateHandler = { path in
                        if path.status == .satisfied {
                            print("Internet connection is available.")
                            // Perform actions when internet is available
                        } else {
                            print("Internet connection is not available.")
                            airplaneAlert = true
                            // Perform actions when internet is not available
                        }
                    }
                    let queue = DispatchQueue(label: "NetworkMonitor")
                    monitor.start(queue: queue)
                } label: {
                    Text("Next >")
                        .bold()
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                        .colorInvert()
                        .background(.primary)
                        .cornerRadius(18)
                        .padding()
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .background(Color.primary.colorInvert())
        .onDisappear {
            isTextFieldFocused = false
        }
        .offset(x: done ? -deviceWidth : 0)
        .alert("Turn off Airplane Mode",
           isPresented: $airplaneAlert,
                   actions: {
                Button("Ok", role: .cancel) {
                    // Do nothing, just dismiss
                }
            },
                   message: {
                Text("Turn off Airplane Mode, and connect to the internet to continue onboarding")
            })
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
                imgCachePath = nil
            }
        }
    }
}

#Preview {
    DemoView()
        .environmentObject(AIChatModel())
}
