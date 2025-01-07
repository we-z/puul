//
//  HomeView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/26/23.
//

import SwiftUI

struct HomeView: View {
    @State private var showLink = false
    @State private var showAccount = false
    @State private var showChat = false
    @EnvironmentObject public var model: AppModel

    @AppStorage("welcomeScreenShown")
    var welcomeScreenShown: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("💼")
                                .font(.system(size: UIScreen.main.bounds.height * 0.04))
                                .offset(y: -4)
                            Text("Portfolio:")
                                .bold()
                                .foregroundColor(.primary)
                                .font(.system(size: UIScreen.main.bounds.height * 0.036))
                        }
                        .padding(.top)
                        Text("$32,232")
                            .bold()
                            .font(.system(size: UIScreen.main.bounds.height * 0.069))
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .padding(.bottom)
                    }
                    Spacer()
                    VStack {
                        Button(action: {
                            self.showAccount = true
                        }) {
                            Text("👤")
                                .font(.system(size: UIScreen.main.bounds.height * 0.039))
                        }
                        .buttonStyle(HapticButtonStyle())
                        Spacer()
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.09)
                    }
                }
                .padding(.horizontal)
                Divider()
                    .overlay(.primary)
                    .padding(.horizontal)
                
                Spacer()

                VStack {
                    HStack {
                        Button(action: {
                            self.showChat = true
                        }) {
                            HStack {
                                Spacer()
                                HStack {
                                    Text("Ask Puul")
                                    Text("✨")
                                        .scaleEffect(1.2)
                                        .offset(y: -3)
                                }
                                .font(.system(size: 30))
                                .padding()
                                .bold()

                                Spacer()
                            }
                            .background(.primary.opacity(0.15))
                            .cornerRadius(20)
                            .overlay( /// apply a rounded border
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.primary, lineWidth: 3)
                            )
                        }
                        .buttonStyle(HapticButtonStyle())
                        .padding()
                    }
                }
            }
            .alert(isPresented: $model.showingWarningAlert) {
                Alert(title: Text("Wait a couple of seconds for changes to appear"))
            }
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView()
                .buttonStyle(HapticButtonStyle())
        }
        .sheet(isPresented: $showAccount) {
            AccountView()
        }
        .sheet(isPresented: $welcomeScreenShown,
               onDismiss: {
                   self.welcomeScreenShown = false
               }) {
            WelcomeView()
                .presentationDetents([.height(660)])
                .buttonStyle(HapticButtonStyle())
        }
        .accentColor(.primary)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreVM())
            .environmentObject(AppModel())
            .environmentObject(ZillowAPI())
    }
}
