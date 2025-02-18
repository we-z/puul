import SwiftUI
import Foundation

struct TempView: View {
    @State private var message = "hello how are you \n\t are you ok? email : hung.phuoc.tran@gmail.com"
    @State private var textStyle = UIFont.TextStyle.body
    var body: some View {
        TextView(text: $message, textStyle: $textStyle)
            .padding(.horizontal)
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}

class CVEDictTextView: UITextView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Create a custom menu item titled "Copy" that triggers copyHighlightedText()
        let customMenuItem = UIMenuItem(title: "Copy", action: #selector(copyHighlightedText))
        UIMenuController.shared.menuItems = [customMenuItem]
        
        if action == #selector(copyHighlightedText) {
            return true
        }
        return false
    }
    
    @objc func copyHighlightedText() {
        // Ensure that some text is selected
        if self.selectedRange.length > 0, let textContent = self.text {
            let startIndex = textContent.index(textContent.startIndex, offsetBy: self.selectedRange.location)
            let endIndex = textContent.index(startIndex, offsetBy: self.selectedRange.length)
            let highlightedText = String(textContent[startIndex..<endIndex])
            UIPasteboard.general.string = highlightedText
            print("Copied: \(highlightedText)")
        }
    }
}

struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle
    
    func makeUIView(context: Context) -> UITextView {
        let textView = CVEDictTextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        
        init(_ text: Binding<String>) {
            self.text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}
