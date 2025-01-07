import Foundation
import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var messages = [BardMessage]()

    private let bard = Bard(token: "ZQi1OHkQEoyD2_pIRfB2-rsNkfiX_Ne_nQVmmJ9Ope4l8goggnffsZpF6V-xdliPOkgw0A.")

    var body: some View {
        ScrollView {
            VStack {
                ForEach($messages, id: \.self) { message in
                    HStack {
                        Text(message.text.wrappedValue)
                    }
                }
                Spacer()
                TextField("Enter your message", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send Message")
                        .foregroundColor(.primary)
                }
            }
        }
    }

    func sendMessage() {
        bard.getAnswer(inputText: inputText) { result in
            switch result {
            case let .success(response):
                let message = BardMessage(id: 0, text: response["text"] as! String, isUserMessage: false)
                messages.append(message)
            case let .failure(error):
                print(error)
            }
        }
        inputText = ""
    }
}

struct BardMessage: Identifiable, Hashable {
    let id: Int
    var text: String
    var isUserMessage: Bool
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
