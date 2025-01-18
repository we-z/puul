//
//  MessageView.swift
//  AlpacaChatApp
//
//  Created by Yoshimasa Niwa on 3/20/23.
//

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
                    .font(.caption)
                    .foregroundColor(.accentColor)
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
            switch message.state {
            case .none:
                VStack(alignment: .leading) {
                    ProgressView()
                    if status != nil{
                        Text(status!)
                            .font(.footnote)
                    }
                }

            case .error:
                Text(message.text)
                    .foregroundColor(Color.red)
                    .textSelection(.enabled)

            case .typed:
                VStack(alignment: .leading) {
//                    if message.header != ""{
//                        Text(message.header)
//                            .font(.footnote)
//                            .foregroundColor(Color.gray)
//                            .textSelection(.enabled)
//                    }
                    MessageImage(message: message)
                    if sender == .user_rag{
                        VStack{
                            Button(
                                action: {
                                    showRag = !showRag
                                },
                                label: {
                                    if showRag{
                                        Text("Hide")
                                            .font(.footnote)
                                    }else{
                                        Text("Show text")
                                            .font(.footnote)
                                    }
                                }
                            )
                            .buttonStyle(.borderless)
                            //                        .frame(maxWidth:50,maxHeight: 50)
                            if showRag{
                                Text(LocalizedStringKey(message.text)).font(.footnote).textSelection(.enabled)
                            }
                        }.textSelection(.enabled)
                    }else{
                        Text(LocalizedStringKey(message.text))
                            .textSelection(.enabled)
                    }
                }.textSelection(.enabled)

            case .predicting:
                HStack {
                    Text(message.text).textSelection(.enabled)
                    ProgressView()
                        .padding(.leading, 3.0)
                        .frame(maxHeight: .infinity,alignment: .bottom)
                }.textSelection(.enabled)

            case .predicted(totalSecond: let totalSecond):
                VStack(alignment: .leading) {
                    switch chatStyle {
                    case "DocC":
                        Markdown(message.text).markdownTheme(.docC).textSelection(.enabled)
                    case "Basic":
                        Markdown(message.text).markdownTheme(.basic).textSelection(.enabled)
                    case "GitHub":
                        Markdown(message.text).markdownTheme(.gitHub).textSelection(.enabled)
                    default:
                        Text(message.text).textSelection(.enabled).textSelection(.enabled)
                    }
//                    Text(String(format: "%.2f ses, %.2f t/s", totalSecond,message.tok_sec))
//                        .font(.footnote)
//                        .foregroundColor(Color.gray)
                }.textSelection(.enabled)
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
                MessageContentView(message: message, 
                                   chatStyle: $chatStyle,
                                   status:$status,
                                   sender: message.sender)
                    .padding(12.0)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(24)
            }

            if message.sender == .system {
                Spacer()
            }
        }
    }
}

// struct MessageView_Previews: PreviewProvider {
//     static var previews: some View {
//         VStack {
//             MessageView(message: Message(sender: .user, state: .none, text: "none", tok_sec: 0))
//             MessageView(message: Message(sender: .user, state: .error, text: "error", tok_sec: 0))
//             MessageView(message: Message(sender: .user, state: .predicting, text: "predicting", tok_sec: 0))
//             MessageView(message: Message(sender: .user, state: .predicted(totalSecond: 3.1415), text: "predicted", tok_sec: 0))
//         }
//     }
// }
