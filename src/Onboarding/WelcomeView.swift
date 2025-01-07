//
//  WelcomeView.swift
//  Hushpost
//
//  Created by Wheezy Capowdis on 12/30/24.
//

import SwiftUI

struct WelcomeView: View {
    @State var done: Bool = false
    var body: some View {
        VStack {
            Spacer()
            VStack {
                // Large SF Symbol icon
                ZStack{
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(120)
                        .padding()
                }
                
                // Title
                Text("Welcome to Puul!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Description
                Text("Plan, manage, and grow your finances with intelligent insights and personalized advice!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
            // MARK: - Next / Rate Us Button
            Button{
                withAnimation(.easeInOut) {
                    done = true
                }
            } label: {
                Text("Continue")
                    .bold()
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(21)
                    .padding()
            }
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .offset(x: done ? -500 : 0)
    }
}

#Preview {
    WelcomeView()
}
