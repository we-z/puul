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
                HStack{
                    Text("Welcome \nto Puul 👋")
                        .font(.system(size: UIScreen.main.bounds.width * 0.17))
                        .padding()
                        .padding(.top, 33)
                        .bold()
                    Spacer()
                }
                HStack{
                    Text("Start talking with your Ai financial advisor 🤝")
                        .font(.system(size: UIScreen.main.bounds.width * 0.08))
                        .padding()
                    Spacer()
                }
                HStack{
                    Text("Add your assets to track your total portfolio 📈")
                        .font(.system(size: UIScreen.main.bounds.width * 0.08))
                        .padding()
                    Spacer()
                }
                HStack{
                    Text("Puul will give you better financial advice when you add your assets and risk tolerance 🏦")
                        .font(.system(size: UIScreen.main.bounds.width * 0.08))
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
                .background(Color.gray.opacity(0.21))
                .cornerRadius(45)
                .padding(.horizontal)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
