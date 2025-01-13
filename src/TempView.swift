import SwiftUI

struct TempView: View {
    @State var add_chat_dialog = false
    @State var edit_chat_dialog = false
    @State var model_name = ""
    @State var title = ""
    @State private var chat_selection: Dictionary<String, String>?
    @State var after_chat_edit: () -> Void = {}
    @StateObject var aiChatModel = AIChatModel()
    
    func close_chat() -> Void{
        aiChatModel.stop_predict()
    }
    
    var body: some View {
        ChatView(
            modelName: $model_name,
            chatSelection: $chat_selection,
            title: $title,
            CloseChat:close_chat,
            AfterChatEdit: $after_chat_edit,
            addChatDialog:$add_chat_dialog,
            editChatDialog:$edit_chat_dialog
            ).environmentObject(aiChatModel)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}


struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
