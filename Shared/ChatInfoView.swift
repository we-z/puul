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
    @EnvironmentObject public var model: AppModel
    let levels = ["Risk-Averse", "Low Risk", "Average Risk", "High Risk", "YOLO"]
    let terms = ["Short Term", "Long Term"]
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
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
            Form {
            ScrollView{
                HStack{
                    Text("Who is Steve?")
                        .font(.system(size: UIScreen.main.bounds.width * 0.1))
                        .bold()
                    Spacer()
                }
                .padding(.vertical)
                
                HStack{
                    Text("Steve is your Ai financial advisor and partner that can help you plan for the future. Whether you are planing for retirement, or simply creating a personal budget, it doesn't hurt to get help from an expert. \n\nSteve gives you personally tailored advice based on your current financial state and desired risk level")
                        .font(.system(size: UIScreen.main.bounds.width * 0.045))
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                }
                .padding(.bottom)
                Divider()
                HStack{
                    Text("What does Steve know about me?")
                        .font(.system(size: UIScreen.main.bounds.width * 0.07))
                        .bold()
                    Spacer()
                }
                .padding(.top)
                HStack{
                    Text("Steve can see your last 10 transactions from every bank account you link and can see what stocks / ETFs you own in each Broker account you link")
                        .font(.system(size: UIScreen.main.bounds.width * 0.045))
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                }
                .padding(.vertical, 3)
            }
            
                Picker("Risk Level", selection: $model.selectedRiskLevel) {
                    ForEach(levels, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.inline)
                .accentColor(.primary)
                Picker("Investing Time frame", selection: $model.selectedTimeFrame) {
                    ForEach(terms, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.inline)
                .accentColor(.primary)
                
                HStack{
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        HStack{
                            Spacer()
                            Text("Clear chat history")
                                .padding()
                                .foregroundColor(.red)
                                .bold()
                                
                            Spacer()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
                
            
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
            .environmentObject(AppModel())
    }
}
