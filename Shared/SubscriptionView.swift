//
//  SubscriptionView.swift
//  storekit2-youtube-demo-part-2
//
//  Created by Paulo Orquillo on 2/03/23.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var storeVM: StoreVM
    @State var isPurchased = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack{
            VStack{
                HStack{
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Later")
                            .accentColor(.primary)
                    }
                }
                .padding(.horizontal)
                HStack {
                    Text("Achieve Financial Freedom")
                        .font(.system(size: UIScreen.main.bounds.width * 0.19))
                        .bold()
                        .padding()
                    Spacer()
                }
            }
            .background(.primary.opacity(0.1))
            
            HStack{
                VStack(alignment: .leading, spacing: 30){
                    HStack{
                        Image(systemName: "message")
                        Text("Unlimited questions")
                    }
                    HStack{
                        Image(systemName: "dollarsign.circle")
                        Text("Add unlimited assets")
                    }
                    HStack{
                        Image(systemName: "house")
                        Text("Ai Real Estate Advisor")
                    }
                }
                .bold()
                .font(.system(size: UIScreen.main.bounds.width * 0.07))
                .padding(.horizontal)
                //Spacer()
            }
            .padding(.top, UIScreen.main.bounds.height * 0.06)
            Spacer()
            Group {
                Section {
                    ForEach(storeVM.subscriptions) { product in
                        Button(action: {
                            Task {
                                await buy(product: product)
                            }
                        }
                        ){
                            VStack {
                                
                                HStack {
                                    Text(product.displayPrice)
                                    Text("/")
                                    Text(product.displayName)
                                    Spacer()
                                }
                                .font(.system(size: 27))
                                .padding(.leading)
                                .bold()
                            }
                            .padding()
                            .padding(.vertical, 6)
                            
                        }
                        .foregroundColor(.primary)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(39)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    func buy(product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("purchase failed")
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView().environmentObject( StoreVM())
    }
}
