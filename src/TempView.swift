import SwiftUI

struct TempView: View {
    @State var add_chat_dialog = false
    @State var edit_chat_dialog = false
    @State private var chat_selection: Dictionary<String, String>?
    @StateObject var aiChatModel = AIChatModel()
    
    func close_chat() -> Void{
        aiChatModel.stop_predict()
    }
    
    var body: some View {
        ChatView(
            chatSelection: $chat_selection,
            CloseChat:close_chat,
            addChatDialog:$add_chat_dialog,
            editChatDialog:$edit_chat_dialog
            ).environmentObject(aiChatModel)
    }
}


struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
