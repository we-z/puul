//
//  ChatInfoView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/30/23.
//

import SwiftUI

struct ChatInfoView: View {
    @State private var showingAlert = false
    @Environment(\.dismiss) private var dismiss
    @Binding var shouldClearConversation: Bool
    var body: some View {
        VStack{
            HStack{
                Text("Who is Steve?")
                    .font(.system(size: UIScreen.main.bounds.width * 0.12))
                    .bold()
                Spacer()
            }
            .padding(.top)
            .padding()
            HStack{
                Text("Steve is your Ai financial advisor and partner that can help you plan for the future. Whether you are planing for retirement, or simply creating a personal budget, it doesn't hurt to get help from an expert.")
                    .font(.system(size: UIScreen.main.bounds.width * 0.06))
                    .multilineTextAlignment(.leading)
                    .italic()
                Spacer()
            }
            .padding(.vertical, 3)
            .padding()
            HStack{
                Text("What's happening to my data?")
                    .font(.system(size: UIScreen.main.bounds.width * 0.1))
                    .bold()
                Spacer()
            }
            .padding()
            HStack{
                Text("All conversations between you and steve live on your device and are only accesible to you. You may feel free to clear your entire thread at any time by pressing clear conversation")
                    .font(.system(size: UIScreen.main.bounds.width * 0.06))
                    .multilineTextAlignment(.leading)
                    .italic()
                Spacer()
            }
            .padding()
            .padding(.vertical, 3)
            Spacer()
            HStack{
                Button(action: {
                    self.showingAlert = true
                }) {
                    Spacer()
                    Text("Clear Conversations")
                        .padding()
                    Spacer()
                }
                .foregroundColor(.primary)
                .bold()
                .background(
                    ZStack{
                        Color.primary.colorInvert()
                        Color.primary.opacity(0.18)
                    }
                )
                .cornerRadius(32)
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(title: Text("Are you sure?"),
                  message: Text("All conversations with Steve will be permenantly deleted"),
                  primaryButton: .destructive(Text("Delete")) {
                print("clearing from chat info view")
                shouldClearConversation = true
                dismiss()
                        
            }, secondaryButton: .cancel(){}
            )
        }
    }
    
}

struct ChatInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoView(shouldClearConversation: .constant(false))
    }
}
