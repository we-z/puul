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
        VStack {
            Capsule()
                .frame(maxWidth: 45, maxHeight: 9)
                .padding(.top, 9)
                .foregroundColor(.primary)
                .opacity(0.3)
            Spacer()
            HStack {
                Text("Account")
                    .font(.title)
            }
            .bold()
            .padding()
            List {
                Section(header: Text("Account")) {
                    Button(action: {
                        if !model.isPurchased {
                            self.showSubscriptions = true
                        } else {
                            showManageSubscriptions = true
                        }
                    }) {
                        HStack {
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
                        HStack {
                            Image(systemName: "info.circle")
                            Text("About Puul")
                        }
                    }
                }
                .listRowBackground(Color.primary.opacity(0.12))
                Section(header: Text("Settings")) {
                    Toggle(isOn: $model.isLightMode) {
                        HStack {
                            Image(systemName: "sun.max")
                            Text("Light Mode")
                        }
                    }
                    Toggle(isOn: $model.hapticModeOn) {
                        HStack {
                            Image(systemName: "waveform")
                            Text("Haptic Feedback")
                        }
                    }
                }
                .listRowBackground(Color.primary.opacity(0.12))
                Section(header: Text("About")) {
                    Button(action: {
                        if let url = URL(string: "https://puul.ai/terms-of-use") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "newspaper")
                            Text("Terms of Use")
                        }
                    }
                    Button(action: {
                        if let url = URL(string: "https://puul.ai/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
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
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Contact Us")
                        }
                    }
                    Button(action: {
                        requestReview()
                    }) {
                        HStack {
                            Image(systemName: "star")
                            Text("Rate Us")
                        }
                    }
                }
                .listRowBackground(Color.primary.opacity(0.12))
            }
            .scrollContentBackground(.hidden)
        }
        .accentColor(.primary)
        .sheet(isPresented: $showSubscriptions) {
            SubscriptionView()
                .presentationDetents([.height(560)])
        }
        .sheet(isPresented: $showDataInfo,
               onDismiss: {
                   self.showDataInfo = false
               },
               content: {
                   AppInfoView()
                       .buttonStyle(HapticButtonStyle())
               })
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        // .environmentObject(StoreVM())
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AppModel())
            .environmentObject(StoreVM())
    }
}
