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
            Text("Puul Q&A")
                .bold()
                .font(.title2)
                .padding()
            Form {
                ScrollView {
                    HStack {
                        Text("What is Puul?")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical)

                    HStack {
                        Text("Puul is your Ai financial advisor and partner that can help you plan for the future. Whether you are planning for retirement, or simply creating a personal budget, it doesn't hurt to get help from an expert. \n\nPuul gives you personally tailored advice based on your current financial state and desired risk level")
                            .font(.system(size: UIScreen.main.bounds.width * 0.045))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(.bottom)
                    Divider()
                    HStack {
                        Text("What does Puul know about me?")
                            .font(.system(size: UIScreen.main.bounds.width * 0.07))
                            .bold()
                        Spacer()
                    }
                    .padding(.top)
                    HStack {
                        Text("Puul can see your last 100 transactions from every bank account you link and can see what stocks / ETFs you own in each Broker account you link")
                            .font(.system(size: UIScreen.main.bounds.width * 0.045))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(.vertical, 3)
                    Divider()
                        .padding(.top)
                    HStack {
                        Text("Why?")
                            .font(.system(size: UIScreen.main.bounds.width * 0.1))
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical)
                    HStack {
                        Text("The biggest advantage of Puul over a human advisor is its ability to process vast amounts of data quickly and make data-driven recommendations. \n \nUnlike human advisors, Puul is not influenced by emotional biases, which can impact decision-making.")
                            .font(.system(size: UIScreen.main.bounds.width * 0.045))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                }
            }
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
