import SwiftUI

struct ContentView: View {
    
    @State var text: String = ""

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                // ...
                Text("Hello")
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    TextField("Send message", text: $text, axis: .vertical)
                        .background(.gray)
                        .padding()
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
