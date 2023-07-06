//
//  MessageRowView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import SwiftUI

struct MessageRowView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var imageSize: CGSize {
        #if os(iOS) || os(macOS)
        CGSize(width: 25, height: 25)
        #elseif os(watchOS)
        CGSize(width: 20, height: 20)
        #else
        CGSize(width: 80, height: 80)
        #endif
    }
    
    var body: some View {
        VStack(spacing: 0) {
            messageRow(text: message.sendText, image: message.sendImage)
            
            if let text = message.responseText {
                Divider()
                    .overlay(.gray)
                    .padding(.horizontal)
                messageRow(text: text, image: message.responseImage, responseError: message.responseError, showDotLoading: message.isInteractingWithChatGPT)
                Divider()
                    .overlay(.gray)
                    .padding(.horizontal)
            }
        }
    }
    
    func messageRow(text: String, image: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        #if os(watchOS)
        VStack(alignment: .leading, spacing: 8) {
            messageRowContent(text: text, image: image, responseError: responseError, showDotLoading: showDotLoading)
        }
        
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        //.background(bgColor)
        #else
        HStack(alignment: .top, spacing: 24) {
            messageRowContent(text: text, image: image, responseError: responseError, showDotLoading: showDotLoading)
        }
        #if os(tvOS)
        .padding(32)
        #else
        .padding(16)
        #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        //.background(bgColor)
        #endif
    }
    
    @ViewBuilder
    func messageRowContent(text: String, image: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        
        Image(systemName: image)
            .resizable()
            .frame(width: imageSize.width, height: imageSize.height)
        
        VStack(alignment: .leading) {
            if !text.isEmpty {
                Text(text)
                    .tracking(1)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            
            if let error = responseError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                
                Button("Regenerate response") {
                    retryCallback(message)
                }
                .foregroundColor(.accentColor)
                .padding(.top)
            }
            
            if showDotLoading {
                #if os(tvOS)
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                #else
                DotLoadingView()
                    .frame(width: 60, height: 30)
                #endif
                
            }
        }
    }
    
    #if os(tvOS)
    private func rowsFor(text: String) -> [String] {
        var rows = [String]()
        let maxLinesPerRow = 8
        var currentRowText = ""
        var currentLineSum = 0
        
        for char in text {
            currentRowText += String(char)
            if char == "\n" {
                currentLineSum += 1
            }
            
            if currentLineSum >= maxLinesPerRow {
                rows.append(currentRowText)
                currentLineSum = 0
                currentRowText = ""
            }
        }

        rows.append(currentRowText)
        return rows
    }
    
    
    func responseTextView(text: String) -> some View {
        ForEach(rowsFor(text: text), id: \.self) { text in
            Text(text)
                .focusable()
                .multilineTextAlignment(.leading)
        }
    }
    #endif
    
}

//struct MessageRowView_Previews: PreviewProvider {
//
//    static let message = MessageRow(
//        isInteractingWithChatGPT: true, sendImage: "profile",
//        sendText: "What is SwiftUI?",
//        responseImage: "openai",
//        responseText: "SwiftUI is a user interface framework that allows developers to design and develop user interfaces for iOS, macOS, watchOS, and tvOS applications using Swift, a programming language developed by Apple Inc.")
//
//    static let message2 = MessageRow(
//        isInteractingWithChatGPT: false, sendImage: "profile",
//        sendText: "What is SwiftUI?",
//        responseImage: "openai",
//        responseText: "",
//        responseError: "ChatGPT is currently not available")
//
//    static var previews: some View {
//        NavigationStack {
//            ScrollView {
//                MessageRowView(message: message, retryCallback: { messageRow in
//
//                })
//
//                MessageRowView(message: message2, retryCallback: { messageRow in
//
//                })
//
//            }
//            .frame(width: 400)
//            .previewLayout(.sizeThatFits)
//        }
//    }
//}
