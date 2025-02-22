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
