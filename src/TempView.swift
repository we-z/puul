import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @Environment (\.colorScheme) var colorScheme
    var body: some View {
        VStack{
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { request in
                
            }
            .signInWithAppleButtonStyle(
                colorScheme ==  .dark ? .white : .black
            )
            .frame (height: 50)
            .padding()
            .cornerRadius(9)
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
