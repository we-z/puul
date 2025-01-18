//
//  ChatItem.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 6/08/21.
//

import SwiftUI



struct ChatItem: View {
    
    var chatImage: String = ""
    var chatTitle: String = ""
    var message: String = ""
    var time: String = ""
    var model: String = ""
    var chat: String = ""
    var model_size: String = ""
    //    @Binding var chat_selection: String?
    @Binding var model_name: String
    @Binding var title: String
    var close_chat: () -> Void
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text(chatTitle)
                        .font(.system(size: 21))
                        .bold()
                        .fontWeight(.semibold)
                        .padding()
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
    }
}
