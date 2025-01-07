//
//  HomeView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/26/23.
//

import SwiftUI

struct Security: Identifiable {
    var id = UUID()
    var name: String
    var ticker: String
    var sector: String
    var holdingSize: String
    var costBasis: String
    var currentMarketValue: String
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Puul")
                                .bold()
                                .foregroundColor(.primary)
                                .font(.largeTitle)
                            Spacer()
                            Image(systemName: "person.circle")
                                .font(.system(size: 36))
                        }
                        Text("Total net worth")
                            .bold()
                            .foregroundColor(.primary)
                            .font(.system(size: 30))
                            .opacity(0.7)
                            .padding(.top)
                        Text("$34,632,894.50")
                            .bold()
                            .foregroundColor(.primary)
                            .font(.system(size: 45))
                        HStack {
                            Image(systemName: "triangle.fill").foregroundColor(.green)
                            Text("$46,874 (1.12%)").font(.system(size: 21))
                            Text("Past Month").bold().font(.system(size: 21))
                        }
                        // Spacer()
                    }
                    .padding(.horizontal)
                    Stocks()
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 60))
                    }
                    .padding(.horizontal)
                }
            }
        }
        .accentColor(.primary)
    }
}

struct Stocks: View {
    var securities: [Security] = [
        Security(name: "Charles Schwab:", ticker: "AAPL", sector: "Technology", holdingSize: "100,000 shares", costBasis: "$10,000,000", currentMarketValue: "$12,738,827"),
        Security(name: "Vanguard:", ticker: "AMZN", sector: "Technology", holdingSize: "50,000 shares", costBasis: "$5,000,000", currentMarketValue: "$6,525,245"),
        Security(name: "Bank of America:", ticker: "BRK.A", sector: "Financials", holdingSize: "25,000 shares", costBasis: "$2,500,000", currentMarketValue: "$3,125,000"),
        Security(name: "Exxon Mobil Corp:", ticker: "XOM", sector: "Energy", holdingSize: "75,000 shares", costBasis: "$7,500,000", currentMarketValue: "$8,750,000"),
        Security(name: "JPMorgan Chase & Co:", ticker: "JPM", sector: "Financials", holdingSize: "50,000 shares", costBasis: "$5,000,000", currentMarketValue: "$5,500,000"),
    ]

    var body: some View {
        List {
            ForEach(securities) { security in
                ZStack {
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    } // .opacity(0)
                    VStack {
                        Spacer()
                        HStack {
                            Text(security.name)
                                .font(.system(size: 27))
                                .bold()
                            Spacer()
                        }
                        Spacer(minLength: 3)
                        HStack {
                            Text(security.currentMarketValue)
                                .font(.system(size: 36))
                                .bold()
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
