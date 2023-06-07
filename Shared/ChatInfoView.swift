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
    @State private var selectedRiskLevel = ""
    let levels = ["Risk-Averse", "Low Risk", "Average Risk", "High Risk", "YOLO"]
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                }
                .accentColor(.primary)
                Spacer()
                Text("About Steve")
                    
                Spacer()
                Text("     ")
            }
            .bold()
            .font(.system(size: 21))
            .padding()
            ScrollView{
                HStack{
                    Text("Who is Steve?")
                        .font(.system(size: UIScreen.main.bounds.width * 0.12))
                        .bold()
                    Spacer()
                }
                .padding()
                HStack{
                    Text("Steve is your Ai financial advisor and partner that can help you plan for the future. Whether you are planing for retirement, or simply creating a personal budget, it doesn't hurt to get help from an expert. \n\nSteve gives you personally tailored advice based on your current financial state and desired risk level")
                        .font(.system(size: UIScreen.main.bounds.width * 0.045))
                        .multilineTextAlignment(.leading)
                        .italic()
                    Spacer()
                }
                .padding(.vertical, 3)
                .padding()
                
                HStack{
                    Text("What does Steve know about me?")
                        .font(.system(size: UIScreen.main.bounds.width * 0.1))
                        .bold()
                    Spacer()
                }
                .padding()
                HStack{
                    Text("Steve can see your last 10 transactions from every bank account you link and can see what stocks / ETFs you own in each Broker account you link")
                        .font(.system(size: UIScreen.main.bounds.width * 0.045))
                        .multilineTextAlignment(.leading)
                        .italic()
                    Spacer()
                }
                .padding(.vertical, 3)
                .padding()
            }
            Form {
                Picker("Risk Level", selection: $selectedRiskLevel) {
                    ForEach(levels, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.inline)
                .accentColor(.primary)
            }
            .scrollDisabled(true)
                
            HStack{
                Button(action: {
                    self.showingAlert = true
                }) {
                    HStack{
                        Spacer()
                        Text("Clear chat history")
                            .padding()
                            .foregroundColor(.primary)
                            .bold()
                            
                        Spacer()
                    }
                    .background(
                        ZStack{
                            Color.primary.colorInvert()
                            Color.primary.opacity(0.18)
                        }
                    )
                    .cornerRadius(32)
                }
                .padding(.horizontal)
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
