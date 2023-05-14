//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
        
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        chatListView
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 24))
                        }
                    }
                    Spacer()
                    Text("Puul")
                        .bold()
                    Spacer()
                    Button("Clear") {
                        vm.clearMessages()
                    }
                    .disabled(vm.isInteractingWithChatGPT)
                }
                .padding()
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
        //.scrollDismissesKeyboard(.immediately)
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "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")))
//        }.accentColor(.primary)
//    }
//}
