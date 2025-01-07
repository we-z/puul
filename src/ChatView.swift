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
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 24))
                    }
                    Spacer()
                    Text("Puul")
                        .font(.system(size: 21))
                        .bold()
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "square.and.pencil")
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
                            HStack(spacing: 10) {
                                ForEach(financialQuestions, id: \.self) { question in
                                    Button {
                                        message = question
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
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .background(.primary.opacity(0.001))
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .onAppear {
                        isTextFieldFocused = true
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
            Task { @MainActor in
                isTextFieldFocused = false
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
    }
}
