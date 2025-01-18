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

    @Binding var tabSelection: Int
    @Binding var model_name: String
    @Binding var title: String
    @Binding var add_chat_dialog: Bool
    var close_chat: () -> Void
    @Binding var edit_chat_dialog: Bool
    @Binding var chat_selection: Dictionary<String, String>?
    @Binding var swiping: Bool
    @Binding var after_chat_edit: () -> Void

    @State var chats_previews: [Dictionary<String, String>] = []
    @State private var toggleSettings = false
    @State private var toggleAddChat = false

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

    func Duplicate(at elem: Dictionary<String, String>) {
        _ = duplicateChat(elem)
        refresh_chat_list()
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                NavigationStack {
                    // Explicitly using SwiftUI.ScrollView to avoid ambiguity
                    ScrollView {
                        ForEach(filteredChats, id: \.self) { chat_preview in
                            HStack {
                                Button {
                                    chat_selection = chat_preview
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
                                Spacer()
                            }
                            .background(.primary.opacity(chat_selection == chat_preview ? 0.2 : 0.001))
                            .cornerRadius(12)
                            .padding(.horizontal)
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
                    }
                    .scrollIndicators(.hidden)
                    .searchable(text: $searchText, isPresented: $isSearching, prompt: Text("Search..."))
                    .refreshable {
                        refresh_chat_list()
                    }
                    
                    .navigationTitle("Sessions")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showSettings = true
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

            if chats_previews.isEmpty {
                VStack {
                    Button {
                        toggleAddChat = true
                        add_chat_dialog = true
                        edit_chat_dialog = false
                    } label: {
                        Image(systemName: "plus.square.dashed")
                            .foregroundColor(.primary)
                            .font(.system(size: 40))
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)

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
        .onChange(of: tabSelection) { _ in
            refresh_chat_list()
        }
        .task {
            after_chat_edit = refresh_chat_list
            refresh_chat_list()
        }
        .sheet(isPresented: $showSettings) {
            AccountView()
                .environmentObject(AppModel())
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(
            tabSelection: .constant(1),
            model_name: .constant(""),
            title: .constant(""),
            add_chat_dialog: .constant(false),
            close_chat: {},
            edit_chat_dialog: .constant(false),
            chat_selection: .constant([:]),
            swiping: .constant(false),
            after_chat_edit: .constant({})
        )
        .environmentObject(AIChatModel())
    }
}
