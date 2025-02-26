import SwiftUI

struct TempView: View {
    @State private var message = """
    Here is the revised suggestion:

    **Slide 1: "Investing Strategies The Ultra Wealthy Use"**
     Title slide, let's get started!

    **Slide 2: "1. Rely On Experts"**
    The ultra wealthy often seek guidance from top experts.

    **Slide 3: "2. Diversify Across Asset Classes"**
    Spread investments across stocks, bonds, real estate & more.

    **Slide 4: "3. Invest in Yourself First"**
    Prioritize personal growth for higher returns.

    **Slide 5: "4. Leverage Tax-Advantaged Strategies"**
    Minimize taxes with smart investing tactics.

    **Slide 6: "5. Long-Term Focus"**
    Wealthy investors look decades ahead, not just quarters.

    Please consider completing your Puul questionnaire on the account page for more accurate and personalized advice!
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

