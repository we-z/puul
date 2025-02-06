//
//  RatingsView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 2/5/25.
//

import SwiftUI

struct RatingsView: View {
    var body: some View {
        VStack {
            Text("My Financial Stats")
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .bold()
                .padding()
            Image(systemName: "chart.bar.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom)
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Overall")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("Total Net Worth")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Credit Score")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("Portfolio Diversity")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Debt to Income Ratio")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                    VStack(alignment: .leading) {
                        Text("Retirement Readiness")
                            .bold()
                        Text("99")
                            .font(.largeTitle)
                            .bold()
                        ProgressView(value: 50, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.primary)
                    }
                    .padding()
                }
            }
            Spacer()
        }
    }
}

#Preview {
    RatingsView()
}
