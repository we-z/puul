//
//  InstallAIView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/10/25.
//

import SwiftUI

struct InstallAIView: View {
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
                Text("Complete installing Puul AI")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Description
                Text("Puul AI is < 1 GB in size and is completely private and runs on your device.")
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
                Text("Install Private AI")
                    .bold()
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .colorInvert()
                    .background(.primary)
                    .cornerRadius(18)
                    .padding()
            }
            .buttonStyle(HapticButtonStyle())
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .offset(x: done ? -500 : 0)
    }
}

#Preview {
    InstallAIView()
}
