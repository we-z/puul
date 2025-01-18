//
//  ChatListView.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 05/08/21.
//

import SwiftUI



struct ChatListView: View {
    @EnvironmentObject var aiChatModel: AIChatModel
    
    @State var searchText: String = ""
    @Binding var tabSelection: Int
    @Binding var model_name: String
    @Binding var title: String
    @Binding var add_chat_dialog: Bool
    var close_chat: () -> Void
    @Binding var edit_chat_dialog: Bool
    @Binding var chat_selection: Dictionary<String, String>?
    @Binding var after_chat_edit: () -> Void
    
    @State var chats_previews: [Dictionary<String, String>] = []
    @State private var toggleSettings = false
    @State private var toggleAddChat = false
    
    func refresh_chat_list(){
        print("refreshing chat list")
        if is_first_run(){
            create_demo_chat()
        }
        self.chats_previews = get_chats_list() ?? []
        aiChatModel.update_chat_params()
    }
    
    func Delete(at offsets: IndexSet) {
        let chatsToDelete = offsets.map { self.chats_previews[$0] }
        _ = deleteChats(chatsToDelete)
        refresh_chat_list()
    }
    
    func Delete(at elem:Dictionary<String, String>){
        _ = deleteChats([elem])
        self.chats_previews.removeAll(where: { $0 == elem })
        refresh_chat_list()
    }
    
    func Duplicate(at elem:Dictionary<String, String>){
        _ = duplicateChat(elem)
        refresh_chat_list()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                NavigationStack {
                    ScrollView {
                        ForEach(chats_previews, id: \.self) { chat_preview in
                            // Instead of NavigationLink, just a row.
                            // When tapped, we set the selection and go to tab 1.
                            Button {
                                // Update the binding with tapped item
                                chat_selection = chat_preview
                                // Animate to ChatView tab
                                withAnimation {
                                    tabSelection = 1
                                }
                            } label: {
                                
                                ChatItem(
                                    chatImage: String(describing: chat_preview["icon"]!),
                                    chatTitle: String(describing: chat_preview["title"]!),
                                    message: String(describing: chat_preview["message"]!),
                                    time: String(describing: chat_preview["time"]!),
                                    model: String(describing: chat_preview["model"]!),
                                    chat: String(describing: chat_preview["chat"]!),
                                    model_size: String(describing: chat_preview["model_size"]!),
                                    model_name: $model_name,
                                    title: $title,
                                    close_chat: close_chat
                                )
                            }
                            .buttonStyle(HapticButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    Duplicate(at: chat_preview)
                                }) {
                                    Text("Duplicate chat")
                                }
                                Button(action: {
                                    Delete(at: chat_preview)
                                }) {
                                    Text("Remove chat")
                                }
                            }
                        }
                        //                    .onDelete(perform: Delete)
                    }
                    .refreshable {
                        refresh_chat_list()
                    }
                    .searchable(text: $searchText, prompt: "Search")
                    .navigationTitle("Sessions")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                            } label: {
                                Image(systemName: "gear")
                            }
                            .buttonStyle(HapticButtonStyle())
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation {
                                    tabSelection = 1
                                }
                            } label: {
                                Image(systemName: "chevron.right.2")
                            }
                            .buttonStyle(HapticButtonStyle())
                        }
                    }
                }
            }
            .background(.opacity(0))
            
            if chats_previews.count <= 0 {
                VStack {
                    Button {
                        toggleAddChat = true
                        add_chat_dialog = true
                        edit_chat_dialog = false
                    } label: {
                        Image(systemName: "plus.square.dashed")
                            .foregroundColor(.secondary)
                            .font(.system(size: 40))
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                    
                    Text("Start new chat")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .opacity(0.4)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onChange(of: tabSelection) { _ in
            refresh_chat_list()
        }
        .task {
            after_chat_edit = refresh_chat_list
            refresh_chat_list()
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(tabSelection: .constant(1),
                     model_name: .constant(""),
                     title: .constant(""),
                     add_chat_dialog: .constant(false),
                     close_chat: {},
                     edit_chat_dialog: .constant(false),
                     chat_selection: .constant([:]),
                     after_chat_edit: .constant({})
        )
        .environmentObject(AIChatModel())
    }
}
