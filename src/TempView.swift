import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
        
    private func convertToPercentEncoding(_ input: String) -> String {
        let allowedCharacterSet = CharacterSet.alphanumerics
        return input.reduce("") { result, char in
            if allowedCharacterSet.contains(char.unicodeScalars.first!) {
                return result + String(char)
            } else {
                return result + "%20"
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Enter text", text: $inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Transformed Text:")
                .font(.headline)
            
            Text(convertToPercentEncoding(inputText))
                .padding()
        }
        .padding()
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
