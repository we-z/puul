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
    @ObservedObject public var storeVM = StoreVM()
    @EnvironmentObject public var model: AppModel
    @Environment(\.requestReview) private var requestReview
    @State private var showManageSubscriptions = false
    
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
                        if !model.isPurchased {
                            self.showSubscriptions = true
                        } else {
                            showManageSubscriptions = true
                        }
                    }) {
                        HStack{
                            Image(systemName: "arrow.clockwise")
                            Text("Subscription")
                            Spacer()
                            if !storeVM.hasUnlockedPro {
                                Text("Free Plan")
                                    .foregroundColor(.gray)
                            } else {
                                Text("Premium Plan")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    Button(action: {
                        self.showDataInfo = true
                    }) {
                        HStack{
                            Image(systemName: "info.circle")
                            Text("About Puul")
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
                    Button(action: {
                        if let url = URL(string: "https://puul.ai/terms-of-use") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack{
                            Image(systemName: "newspaper")
                            Text("Terms of Use")
                        }
                    }
                    Button(action: {
                        if let url = URL(string: "https://puul.ai/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack{
                            Image(systemName: "lock")
                            Text("Privacy Policy")
                        }
                    }
                    Button(action: {
                        let mailtoString = "mailto:inquiries@puul.ai".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let mailtoUrl = URL(string: mailtoString!)!
                        if UIApplication.shared.canOpenURL(mailtoUrl) {
                                UIApplication.shared.open(mailtoUrl, options: [:])
                        }

                    }) {
                        HStack{
                            Image(systemName: "questionmark.circle")
                            Text("Contact Us")
                        }
                    }
                    Button(action: {
                        requestReview()
                    }) {
                        HStack{
                            Image(systemName: "star")
                            Text("Rate Us")
                        }
                    }
                }
            }
            if !model.isPurchased {
                Button(action: {
                    self.showSubscriptions = true
                }) {
                    HStack{
                        Text("⬆️")
                            .scaleEffect(1.2)
                            .offset(y: -1)
                        Text("Upgrade to Pro")
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.primary)
                    .background(.gray.opacity(0.21))
                    .cornerRadius(20)
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.primary, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .font(.system(size: UIScreen.main.bounds.height * 0.033))
                    .bold()
                    
                }
            }
        }
        .accentColor(.primary)
        .sheet(isPresented: $showSubscriptions){
            SubscriptionView()
                .presentationDetents([.height(600)])
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
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        //.environmentObject(StoreVM())
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AppModel())
            .environmentObject(StoreVM())
    }
}
