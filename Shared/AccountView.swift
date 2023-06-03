//
//  AccountView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import SwiftUI

struct AccountView: View {
    @State private var showSubscriptions = false
    @State private var showDataInfo = false
    @Environment(\.dismiss) private var dismiss
    @StateObject var storeVM = StoreVM()
    @EnvironmentObject public var model: AppModel
    
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
                    Button(action: {
                        self.showSubscriptions = true
                    }) {
                        HStack{
                            Image(systemName: "arrow.clockwise")
                            Text("Subscription")
                            Spacer()
                            Text("Free Plan")
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {
                        self.showDataInfo = true
                    }) {
                        HStack{
                            Image(systemName: "info.circle")
                            Text("Data Info")
                        }
                    }
                }
                Section(header: Text("Settings")){
                    Toggle(isOn: $model.isLightMode) {
                        HStack{
                            Image(systemName: "sun.max")
                            Text("Light Mode")
                        }
                    }
                    Toggle(isOn: $model.hapticModeOn) {
                        HStack{
                            Image(systemName: "waveform")
                            Text("Haptic Feedback")
                        }
                    }

                }
                
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
                
            }
        }
        .accentColor(.primary)
        .fullScreenCover(isPresented: $showSubscriptions){
            SubscriptionView()
                .buttonStyle(HapticButtonStyle())
        }
        .sheet(isPresented: self.$showDataInfo,
               onDismiss: {
                   self.showDataInfo = false
               },
            content: {
                AppInfoView()
                .buttonStyle(HapticButtonStyle())
            }
        )
        .preferredColorScheme(model.isLightMode ? .light : .dark)
        .environmentObject(storeVM)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AppModel())
    }
}
