import SwiftUI

struct TempView: View {
    @State private var message = """
    hello how are you\nare you ok? email: hung.phuoc.tran@gmail.com
    """
    @State private var textStyle: UIFont.TextStyle = .body

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

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.isEditable = false
        textView.isSelectable = true
        // ADD THIS:
        textView.isScrollEnabled = false
        textView.text = text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
}
