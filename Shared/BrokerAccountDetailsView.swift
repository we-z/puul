//
//  BrokerAccountDetailsView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/14/23.
//

import SwiftUI

struct BrokerAccountDetailsView: View {
    @State var viewdata: BrokerAccount
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading, spacing: 6){
                    Text(viewdata.institution_name + ":")
                        .bold()
                        .foregroundColor(.primary)
                        .font(.system(size: 36))
                        .opacity(0.7)
                        .padding(.top)
                    Text("$" + viewdata.balance.withCommas())
                        .bold()
                        .font(.system(size: 69))
                    
                }
                .padding()
                Spacer()
            }
            if viewdata.holdings.isEmpty{
                List{
                    Section(header: Text("No Holdings Found").font(.system(size: 40))){
                    }
                }
            } else {
                List{
                    Section(header: Text("Current Holdings").bold().padding(.bottom, 9).font(.system(size: 20))){
                        ForEach(viewdata.holdings) { position in
                            HStack{
                                VStack(alignment: .leading, spacing: 6){
                                    Text(position.name)
                                        .bold()
                                        .font(.system(size: 21))
                                    Text(position.ticker)
                                }
                                Spacer()
                                Text("$" + position.value.withCommas())
                                    .bold()
                                    .font(.system(size: 27))
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
        }
    }
}

struct BrokerAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BrokerAccountDetailsView(viewdata: BrokerAccount(institution_id: "String", access_token: "String", institution_name: "Vanguard", balance: 9043, holdings:
                [
                    Security(ticker: "AAPL", name: "Apple Inc.", value: 432.42),
                    Security(ticker: "TSLA", name: "Tesla Inc.", value: 325.93),
                    Security(ticker: "AMZN", name: "Amazon Inc.", value: 922.75),
                    Security(ticker: "SPY", name: "S&P 500", value: 6782.43),
                    Security(ticker: "TWTR", name: "Twitter Inc", value: 1673.43)
                ]))
    }
}
