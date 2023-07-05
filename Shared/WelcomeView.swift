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
            HStack{
                Text("Welcome to Puul 👋")
                    .font(.system(size: UIScreen.main.bounds.width * 0.2))
                    .padding()
                    .padding(.top, 90)
                Spacer()
            }
            HStack{
                Text("Say hello to Steve, your Ai financial advisor 👨‍💼 \n\nLink your assets to get even more personal suggestions 🏦")
                    .font(.system(size: UIScreen.main.bounds.width * 0.09))
                    .padding()
                Spacer()
            }
            Spacer()
            VStack {
                Button(action:{
                    welcomeScreenShown = false
                }){
                    HStack {
                        Spacer()
                        Text("Continue")
                        Spacer()
                    }
                    .font(.system(size: UIScreen.main.bounds.width * 0.1))
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
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
