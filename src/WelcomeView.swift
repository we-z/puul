//
//  WelcomeView.swift
//  Puul
//
//  Created by Wheezy Salem on 7/4/23.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage ("welcomeScreenShown")
    var welcomeScreenShown: Bool = true
    var body: some View {
        VStack{
            VStack{
                Spacer()
                HStack{
                    Text("Welcome \nto Puul 👋")
                        .font(.system(size: UIScreen.main.bounds.width * 0.17))
                        .padding()
                        .bold()
                    Spacer()
                }
                HStack{
                    Text("Start talking with your Ai financial advisor 🤝")
                        .font(.system(size: UIScreen.main.bounds.width * 0.075))
                        .padding()
                    Spacer()
                }
                HStack{
                    Text("Add your assets to track your total portfolio 📈")
                        .font(.system(size: UIScreen.main.bounds.width * 0.075))
                        .padding()
                    Spacer()
                }
                HStack{
                    Text("Get better financial advice when you add your assets and risk tolerance 🏦")
                        .font(.system(size: UIScreen.main.bounds.width * 0.075))
                        .padding()
                    Spacer()
                }
                Spacer()
            }
            Button(action:{
                welcomeScreenShown = false
            }){
                HStack {
                    Spacer()
                    Text("Continue")
                    Spacer()
                }
                .font(.system(size: UIScreen.main.bounds.width * 0.06))
                .bold()
                .padding()
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(21)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
