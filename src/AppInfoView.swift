//
//  AppInfoView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
                ScrollView {
                    HStack {
                        Text("What is Puul?")
                            .font(.system(size: 27))
                            .bold()
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Text("Puul is your Ai financial advisor and partner that can help you plan for the future. Whether you are planning for retirement, or simply creating a personal budget, it doesn't hurt to get help from an expert. \n\nPuul gives you personally tailored advice based on your current financial state and desired risk level")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()

                    HStack {
                        Text("What does Puul know about me?")
                            .font(.system(size: 27))
                            .bold()
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Text("Puul uses the information you provide in the client questionnaire to create a personalized financial plan that can help you achieve your goals.")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()

                    HStack {
                        Text("Why would I use Puul?")
                            .font(.system(size: 27))
                            .bold()
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Text("The biggest advantage of Puul over any other advisor is its ability to process vast amounts of data quickly and make data-driven recommendations. \n \nUnlike other advisors, Puul is not influenced by emotional biases, which can impact decision-making.")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()
                }
        }
        .navigationTitle("About")
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
