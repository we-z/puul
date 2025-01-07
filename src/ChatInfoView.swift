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
        VStack {
            Capsule()
                .frame(maxWidth: 45, maxHeight: 9)
                .padding(.top, 9)
                .foregroundColor(.primary)
                .opacity(0.3)
            Spacer()
            HStack {
                Text("Puuls Settings")
            }
            .bold()
            .font(.system(size: 21))
            .padding()
            Form {
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

                HStack {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Clear chat history")
                                .padding(12)
                                .foregroundColor(.red)
                                .bold()

                            Spacer()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Are you sure?"),
                  message: Text("All conversations with Puul will be permenantly deleted"),
                  primaryButton: .destructive(Text("Delete")) {
                      print("clearing from chat info view")
                      shouldClearConversation = true
                      dismiss()

                  }, secondaryButton: .cancel {})
        }
    }
}

struct ChatInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoView(shouldClearConversation: .constant(false))
            .environmentObject(AppModel())
    }
}
