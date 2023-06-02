//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit
import Combine

struct ChatView: View {
        
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showInfoPage = false
    @State private var shouldClearConversation = false
    
    var body: some View {
        chatListView
            .onReceive(Just(shouldClearConversation), perform: { shouldClear in
                if shouldClear {
                    vm.clearMessages()  // Call clearMessages() when shouldClearConversation is true
                    shouldClearConversation = false  // Reset the binding value after clearing
                }
            })
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 24))
                    }
                    Spacer()
                    Text("Steve")
                        .font(.system(size: 21))
                        .bold()
                    Spacer()
                    Button {
                        showInfoPage.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24))
                    }
                }
                .padding()
                
                if vm.messages.isEmpty{
                    VStack{
                        Spacer()
                        HStack{
                            Text("Say Hello, Ask your first question")
                            Spacer()
                            VStack{
                                Spacer()
                                    .frame(maxHeight: 120)
                                Image(systemName: "arrow.turn.right.down")
                            }
                        }
                    }
                    .padding(.vertical)
                    .font(.system(size: UIScreen.main.bounds.width * 0.12))
                    .padding(.horizontal, 35)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.messages) { message in
                                MessageRowView(message: message) { message in
                                    Task { @MainActor in
                                        await vm.retry(message: message)
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                    }
                }
                #if os(iOS) || os(macOS)
                Divider()
                bottomView(image: "person", proxy: proxy)
                    .background(.primary.opacity(0.03))
                #endif
            }
            .accentColor(.primary)
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
        
        .sheet(isPresented: self.$showInfoPage,
           onDismiss: {
               self.showInfoPage = false
           }, content: {
               ChatInfoView(shouldClearConversation: $shouldClearConversation)
                   .presentationDragIndicator(.visible)
           }
       )
    }
    
    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Send message", text: $vm.inputMessage, axis: .vertical)
                #if os(iOS) || os(macOS)
                .textFieldStyle(.plain)
                #endif
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)
                .padding(.vertical, 6)
            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 30))
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.primary)
                
                #endif
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(15)
        .padding()
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(vm: ViewModel(api: ChatGPTAPI()))
    }
}
