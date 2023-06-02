//
//  AccountView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import SwiftUI

struct AccountView: View {
    @State var isLightMode = false
    @State var hapticModeOn = false
    @State private var showSubscriptions = false
    @Environment(\.dismiss) private var dismiss
    @StateObject var storeVM = StoreVM()
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
                Text("Account")
                    
                Spacer()
                Text("    ")
            }
            .bold()
            .font(.system(size: 21))
            .padding()
            List{
                Section(header: Text("Account")){
                    HStack{
                        Image(systemName: "arrow.clockwise")
                        Text("Subscription")
                        Spacer()
                        Text("Free Plan")
                            .foregroundColor(.gray)
                    }
                    HStack{
                        Image(systemName: "info.circle")
                        Text("Data Info")
                    }
                }
                Section(header: Text("Settings")){
                    Toggle(isOn: $isLightMode) {
                        HStack{
                            Image(systemName: "sun.max")
                            Text("Light Mode")
                        }
                    }
                    Toggle(isOn: $hapticModeOn) {
                        HStack{
                            Image(systemName: "waveform")
                            Text("Haptic Feedback")
                        }
                    }

                }
                .padding(.vertical, 6)
                
                Section(header: Text("About")){
                    HStack{
                        Image(systemName: "newspaper")
                        Text("Terms of Use")
                    }
                    HStack{
                        Image(systemName: "lock")
                        Text("Privacy Policy")
                    }
                    HStack{
                        Image(systemName: "questionmark.circle")
                        Text("Contact Us")
                    }
                    HStack{
                        Image(systemName: "star")
                        Text("Rate Us")
                    }
                }
            }
            Button(action: {
                self.showSubscriptions = true
            }) {
                HStack{
                    Image(systemName: "arrow.up.circle")
                    Text("Upgrade to Pro")
                    Spacer()
                }
                
                .padding()
                .background(.primary.opacity(0.12))
                .cornerRadius(30)
                .padding(.horizontal)
                .font(.system(size: 30))
                .bold()
                .accentColor(.primary)
            }
        }
        .fullScreenCover(isPresented: $showSubscriptions){
            SubscriptionView()
        }
        .environmentObject(storeVM)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
