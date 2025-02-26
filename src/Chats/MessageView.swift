import SwiftUI
import MarkdownUI

struct MessageView: View {
    var message: Message
    @Binding var chatStyle: String
    @State var status: String?

    private struct SenderView: View {
        var sender: Message.Sender
        var current_model = "LLM"

        var body: some View {
            switch sender {
            case .user:
                Text("")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            case .user_rag:
                Text("RAG")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            case .system:
                Text("Puul")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
        }
    }

    private struct MessageContentView: View {
        var message: Message
        @Binding var chatStyle: String
        @Binding var status: String?
        var sender: Message.Sender
        @State var showRag = false

        var body: some View {
            let processedText: String = {
                if sender == .system {
                    return message.text.replacingOccurrences(of: "\n\n", with: "", options: [], range: message.text.range(of: "\n\n"))
                } else {
                    return message.text
                }
            }()

            switch message.state {
            case .none:
                VStack(alignment: .leading) {
                    ProgressView()
                    if status != nil {
                        Text(status!)
                            .font(.footnote)
                    }
                }

            case .error:
                Text(processedText)
                    .foregroundColor(Color.red)
                    

            case .typed:
                VStack(alignment: .leading) {
                    MessageImage(message: message)
                    if sender == .user_rag {
                        VStack {
                            Button(
                                action: {
                                    showRag = !showRag
                                },
                                label: {
                                    if showRag {
                                        Text("Hide")
                                            .font(.footnote)
                                    } else {
                                        Text("Show text")
                                            .font(.footnote)
                                    }
                                }
                            )
                            .buttonStyle(.borderless)
                            if showRag {
                                Text(LocalizedStringKey(processedText)).font(.footnote)
                            }
                        }
                    } else {
                        Text(LocalizedStringKey(processedText))
                            
                    }
                }

            case .predicting:
                HStack {
                    Markdown(processedText).markdownTheme(.docC)
                    ProgressView()
                        .padding(.leading, 3.0)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }

            case .predicted(totalSecond: _):
                VStack(alignment: .leading) {
                    switch chatStyle {
                    case "DocC":
                        Markdown(processedText).markdownTheme(.docC)
                    case "Basic":
                        Markdown(processedText).markdownTheme(.basic)
                    case "GitHub":
                        Markdown(processedText).markdownTheme(.gitHub)
                    default:
                        Text(processedText)
                    }
                }
            }
        }
    }

    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6.0) {
                SenderView(sender: message.sender)
                if message.sender == .user {
                    MessageContentView(message: message,
                                       chatStyle: $chatStyle,
                                       status: $status,
                                       sender: message.sender)
                    .colorInvert()
                    .padding(12.0)
                    .background(message.sender == .system ? Color.clear : Color.primary)
                    .cornerRadius(24)
                    .padding()
                } else {
                    MessageContentView(message: message,
                                       chatStyle: $chatStyle,
                                       status: $status,
                                       sender: message.sender)
                    .padding(12.0)
                    .background(message.sender == .system ? Color.clear : Color.primary)
                    .cornerRadius(24)
                    .padding()
                }
            }

            if message.sender == .system {
                Spacer()
            }
        }
    }
}
