//
//
//  Created by Alfian Losari on 01/02/23.
//

import AVKit
import Combine
import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showInfoPage = false
    @State private var shouldClearConversation = false
    @State private var showSubscriptions = false
    @State var message = ""
    @EnvironmentObject var storeVM: StoreVM

    var body: some View {
        chatListView
            .onReceive(Just(shouldClearConversation), perform: { shouldClear in
                if shouldClear {
                    shouldClearConversation = false // Reset the binding value after clearing
                }
            })
    }

    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 24))
                    }
                    Spacer()
                    Text("Puul")
                        .font(.system(size: 21))
                        .bold()
                    Spacer()
                    Button {
                        showInfoPage.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                    }
                }
                .padding()

                if true {
                    VStack {
                        Spacer()
                        HStack {
                            Text("Say Hello, Ask your first question")
                            Spacer()
                            VStack {
                                Spacer()
                                    .frame(maxHeight: 120)
                                Image(systemName: "arrow.turn.right.down")
                            }
                        }
                        .padding(.vertical)
                        .font(.system(size: UIScreen.main.bounds.width * 0.12))
                        .padding(.horizontal, 35)
                        ScrollView(.horizontal) {
                            HStack(spacing: -15) {
                                Button {
                                    sendMessage()
                                } label: {
                                    Text("What stocks \nshould I buy?")
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .background(.primary.opacity(0.1))
                                        .cornerRadius(20)
                                        .padding()
                                }
                                Button {
                                    sendMessage()
                                } label: {
                                    Text("how are my \nspending habits?")
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .background(.primary.opacity(0.1))
                                        .cornerRadius(20)
                                        .padding()
                                }
                                Button {
                                    sendMessage()
                                } label: {
                                    Text("What are my \nmonthly expenses?")
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .background(.primary.opacity(0.1))
                                        .cornerRadius(20)
                                        .padding()
                                }
                                Button {
                                    sendMessage()
                                } label: {
                                    Text("how are my \ninvestments?")
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .background(.primary.opacity(0.1))
                                        .cornerRadius(20)
                                        .padding()
                                }
                                Button {
                                    sendMessage()
                                } label: {
                                    Text("How much have \nI spent in may?")
                                        .multilineTextAlignment(.leading)
                                        .padding()
                                        .background(.primary.opacity(0.1))
                                        .cornerRadius(20)
                                        .padding()
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }

                }
                bottomView(image: "person", proxy: proxy)
                    .gesture(
                        swipeGesture
                    )
            }
            .accentColor(.primary)
        }

        .sheet(isPresented: $showInfoPage,
               onDismiss: {
                   self.showInfoPage = false
               }, content: {
                   ChatInfoView(shouldClearConversation: $shouldClearConversation)
                       .presentationDetents([.height(600)])
                       .buttonStyle(HapticButtonStyle())
               })
        .sheet(isPresented: $showSubscriptions) {
            SubscriptionView()
                .presentationDetents([.height(560)])
        }
        .environmentObject(storeVM)
    }

    func bottomView(image _: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message", text: $message, axis: .vertical)
                .textFieldStyle(.plain)
                .focused($isTextFieldFocused)
                .padding(.vertical, 6)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
            }
        }
        .padding(.vertical, 6)
        .padding(.trailing, 9)
        .padding(.leading)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(24)
        .padding()
    }

    func sendMessage() {
        if !storeVM.hasUnlockedPro {
            showSubscriptions = true
        } else {
            Task { @MainActor in
                isTextFieldFocused = false
            }
        }
    }

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50, coordinateSpace: .local)
            .onChanged { value in
                if value.translation.height > 0 {
                    print("down swipe gesture detected!")
                    isTextFieldFocused = false
                }
            }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(StoreVM())
    }
}
