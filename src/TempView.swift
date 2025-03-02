import SwiftUI

@available(iOS 17.0, *)
struct TempView: View {
    @State private var animationsRunning = false

    var body: some View {
        VStack {

            HStack {
                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.iterative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.cumulative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.iterative, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.cumulative, value: animationsRunning)
            }
            .padding()

            HStack {
                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.iterative, options: .repeating, value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.cumulative, options: .repeat(3), value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.iterative, options: .speed(3), value: animationsRunning)

                Image(systemName: "square.stack.3d.up")
                    .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(3).speed(3), value: animationsRunning)
            }
            .padding()
        }
        .font(.largeTitle)
        .onAppear {
            // Start animation instantly when the view appears.
//            withAnimation(.linear(duration: 2)) {
                animationsRunning.toggle()
//            }
//            // Automatically start the animations by repeatedly toggling the state every 2 seconds.
//            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
//                withAnimation(.linear(duration: 2)) {
//                    animationsRunning.toggle()
//                }
//            }
        }
    }
}

@available(iOS 17.0, *)
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
        textView.text = text
        // Add padding to the text view
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        updateText(in: textView)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
    }
    
    private func updateText(in textView: UITextView) {
        let processedText = processMarkdown(text)
        if let attributedMarkdown = try? AttributedString(markdown: processedText) {
            // Convert AttributedString to NSAttributedString
            let nsAttributedString = NSAttributedString(attributedMarkdown)
            let mutableAttributedString = NSMutableAttributedString(attributedString: nsAttributedString)
            // Apply the preferred font for the provided textStyle to the entire string
            mutableAttributedString.addAttribute(
                .font,
                value: UIFont.preferredFont(forTextStyle: textStyle),
                range: NSRange(location: 0, length: mutableAttributedString.length)
            )
            textView.attributedText = mutableAttributedString
        } else {
            // Fallback to plain text if markdown conversion fails
            textView.text = text
            textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        }
    }
    
    /// Processes the markdown text on a per‑line basis:
    /// - For each non‑empty line, append two spaces plus a zero‑width space to enforce a hard break.
    /// - Empty lines are preserved to maintain paragraph breaks.
    private func processMarkdown(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        let processedLines = lines.map { line -> String in
            // If the line isn't empty, append two spaces and a zero‑width space.
            return line.isEmpty ? line : line + " \u{2028}"
        }
        return processedLines.joined()
    }
}

