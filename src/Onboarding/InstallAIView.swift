//
//  InstallAIView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/10/25.
//

import SwiftUI

struct InstallAIView: View {
    @State var done: Bool = false
    @State private var progressValue: Double = -20
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
                Text("Puul AI is a locally hosted AI model < 1 GB in size and is completely private and runs on your device.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
            if progressValue >= 0 {
                ProgressView(value: progressValue, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .frame(width: 250)
                    .padding(.bottom, 20)
            }
            // MARK: - Next / Rate Us Button
            Button{
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if progressValue <= 100 {
                        withAnimation(.spring) {
                            progressValue += 20 // Increment progress by 10 each second
                        }
                    } else {
                        timer.invalidate() // Stop the timer when progress reaches 100
                    }
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
        .onChange(of: progressValue) { newValue in
            // Once progress hits 100, show the final message
            if newValue > 100 {
                withAnimation(.easeInOut) {
                    done = true
                }
            }
        }
    }
}

#Preview {
    InstallAIView()
}
