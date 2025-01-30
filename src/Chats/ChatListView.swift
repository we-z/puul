//
//  ChatListView.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 05/08/21.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var aiChatModel: AIChatModel
    @State private var showSettings = false
    @State var searchText: String = ""
    @State var isSearching: Bool = false

    @Binding var model_name: String
    @Binding var title: String
    @Binding var add_chat_dialog: Bool
    var close_chat: () -> Void
    @Binding var edit_chat_dialog: Bool
    @Binding var chat_selection: Dictionary<String, String>?
    @Binding var swiping: Bool
    @Binding var allowSwiping: Bool
    @Binding var after_chat_edit: () -> Void

    @State var chats_previews: [Dictionary<String, String>] = []
    @State private var toggleSettings = false
    @State private var toggleAddChat = false
    
    @State private var showAccountView = false

    var filteredChats: [Dictionary<String, String>] {
        if searchText.isEmpty {
            return chats_previews
        } else {
            return chats_previews.filter { chat in
                (chat["title"]?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (chat["message"]?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func newChat() {
        // 1) Save the current chat
        aiChatModel.save_chat_history_and_state()
        
        // 2) Clear out in-memory chat data for a new empty session
        aiChatModel.chat = nil
        aiChatModel.messages.removeAll()
        aiChatModel.chat_name = ""
        aiChatModel.model_name = ""
        aiChatModel.Title = ""
        
        // 3) Clear local UI bindings
        title = ""
        chat_selection = [:]
    }

    func refresh_chat_list() {
        print("refreshing chat list")
        if is_first_run() {
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

    func Delete(at elem: Dictionary<String, String>) {
        _ = deleteChats([elem])
        self.chats_previews.removeAll(where: { $0 == elem })
        refresh_chat_list()
    }

//    func Duplicate(at elem: Dictionary<String, String>) {
//        _ = duplicateChat(elem)
//        refresh_chat_list()
//    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                    // Explicitly using SwiftUI.ScrollView to avoid ambiguity
                List(selection: $chat_selection) {
                    ForEach(filteredChats, id: \.self) { chat_preview in
                        HStack {
                            NavigationLink(value: chat_preview) {
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
                            Spacer()
                        }
                        .listRowInsets(.init())
//                        .background(.primary.opacity(chat_selection == chat_preview ? 0.12 : 0.001))
//                        .cornerRadius(12)
                        .padding(.horizontal)
                        .buttonStyle(HapticButtonStyle())
                        .contextMenu {
                            Button(action: {
                                Delete(at: chat_preview)
                            }) {
                                Text("Delete Session")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
                .searchable(text: $searchText, prompt: Text("Search..."))
                .navigationTitle("Sessions")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            // Clear selection on tap
                            chat_selection = nil
                            // Trigger navigation
                            showAccountView = true
                        } label: {
                            Image(systemName: "gear")
                        }
                        .buttonStyle(HapticButtonStyle())
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            newChat()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .buttonStyle(HapticButtonStyle())
                    }
                }
                .navigationDestination(isPresented: $showAccountView) {
                    AccountView()
                        .environmentObject(AppModel())
                }
            }
            .background(.opacity(0))

            if chats_previews.isEmpty {
                VStack {
                    Button {
                        newChat()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.primary)
                            .font(.system(size: 40))
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                    .padding()

                    Text("Start new chat")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
//                .opacity(0.4)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        // Whenever swiping changes, clear search text and dismiss the search
        .onChange(of: swiping) { _ in
            isSearching = false
            searchText = ""
        }
        // Refresh the list whenever the tab changes
        .onChange(of: aiChatModel.messages) { messages in
            Task {
                if messages.count < 2 {                    
                    refresh_chat_list()
                }
            }
        }
        .task {
            refresh_chat_list()
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(
            model_name: .constant(""),
            title: .constant(""),
            add_chat_dialog: .constant(false),
            close_chat: {},
            edit_chat_dialog: .constant(false),
            chat_selection: .constant([:]),
            swiping: .constant(false),
            allowSwiping: .constant(true),
            after_chat_edit: .constant({})
        )
        .environmentObject(AIChatModel())
    }
}
