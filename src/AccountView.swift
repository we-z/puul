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
    @State private var showSurvey = false
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var storeVM = StoreVM()
    @EnvironmentObject public var model: AppModel
    @Environment(\.requestReview) private var requestReview
    @State private var showManageSubscriptions = false
    @State var showStats = false
    
    @State private var selectedTheme = "Dark"
    let themes = ["Dark", "Light", "Automatic"]
    

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Q&A")) {
                        
                        Button(action: {
                            self.showDataInfo = true
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("About Puul")
                            }
                        }
                    }
                    
                    Section(header: Text("Personal")) {
    
                        Button(action: {
                            showSurvey = true
                        }) {
                            HStack {
                                Image(systemName: "checklist")
                                Text("Survey")
                            }
                        }
                        Button(action: {
                            showStats = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar")
                                Text("Financial Stats")
                            }
                        }
                    }
                    Section(header: Text("Settings")) {
                        Button(action: {
                            showManageSubscriptions = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Subscription")
                                Spacer()
                                Text("View")
                                    .foregroundColor(.gray)
                            }
                        }
    
//                        Toggle(isOn: $model.isLightMode) {
//                            HStack {
//                                Image(systemName: "sun.max")
//                                Text("Theme")
//                            }
//                        }
                        HStack {
                            Image(systemName: "sun.max")
                            Text("Theme")
                            Spacer()
                            Picker("Appearance", selection: $selectedTheme) {
                                ForEach(themes, id: \.self) {
                                    Text($0)
                                }
                            }
                            
                        }
                        Toggle(isOn: $model.hapticModeOn) {
                            HStack {
                                Image(systemName: "waveform")
                                Text("Haptic Feedback")
                            }
                        }
                    }
                    //                .listRowBackground(Color.primary.opacity(0.12))
                    Section(header: Text("About")) {
                        Button(action: {
                            if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc")
                                Text("Terms of Use")
                            }
                        }
                        Button(action: {
                            if let url = URL(string: "https://endlessfall-io.firebaseapp.com/privacy-policy/") {
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
                                Image(systemName: "message")
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
                    //                .listRowBackground(Color.primary.opacity(0.12))
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Profile")
            .accentColor(.primary)
            .sheet(isPresented: $showDataInfo,
                   onDismiss: {
                self.showDataInfo = false
            },
                   content: {
                AppInfoView()
                    .buttonStyle(HapticButtonStyle())
            })
            .fullScreenCover(isPresented: $showSurvey) {
                SurveyView()
                    .environmentObject(StoreVM())
            }
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        }
        .sheet(isPresented: $showStats) {
            RatingsView()
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AppModel())
            .environmentObject(StoreVM())
    }
}
