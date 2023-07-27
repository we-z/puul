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
            TabView{
                VStack{
                    HStack{
                        Text("Welcome to Puul 👋")
                            .font(.system(size: UIScreen.main.bounds.width * 0.2))
                            .padding()
                        Spacer()
                    }
                    HStack{
                        Text("All your portfolios, pooled in one place 💼")
                            .font(.system(size: UIScreen.main.bounds.width * 0.09))
                            .padding()
                        Spacer()
                    }
                }
                .offset(y: -UIScreen.main.bounds.height * 0.0)
                VStack{
                    Spacer()
                    HStack{
                        Text("Plan for the future 🚀")
                            .font(.system(size: UIScreen.main.bounds.width * 0.15))
                            .padding()
                            //.padding(.top, 50)
                        Spacer()
                    }
                    HStack{
                        Text("Start talking with your personal Ai financial advisor 🤝")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .padding()
                        Spacer()
                    }
                    HStack{
                        Text("Add your assets to track your total portfolio 📈")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .padding()
                        Spacer()
                    }
                    .padding(.bottom, 85)
                }
                //.offset(y: -UIScreen.main.bounds.height * 0.027)
                VStack{
                    Spacer()
                    HStack{
                        Text("Optimize⚡")
                            .font(.system(size: UIScreen.main.bounds.width * 0.15))
                            .padding()
                            //.padding(.top, 50)
                        Spacer()
                    }
                    HStack{
                        Text("Puul will give you better financial advice when you add your assets 🏦")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .padding()
                        Spacer()
                    }
                    HStack{
                        Text("Choosing your risk tolerance will let Puul give you better investing advice 💸")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .padding()
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                //.offset(y: -UIScreen.main.bounds.height * 0.02)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear() {
                UIPageControl.appearance().currentPageIndicatorTintColor = .label
                UIPageControl.appearance().pageIndicatorTintColor = .gray
            }
            //Spacer()
            
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
