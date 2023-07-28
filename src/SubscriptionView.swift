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
    @Environment(\.dismiss) var dismiss

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
                    Text("Upgrade to \na smarter portfolio")
                        .font(.system(size: UIScreen.main.bounds.width * 0.15))
                        .bold()
                        .padding()
                    Spacer()
                }
            }
            //.background(.primary.opacity(0.1))
            Divider()
                .overlay(.primary)
                .padding(.horizontal)
            
            HStack{
                VStack(alignment: .leading, spacing: 36){
                    HStack{
                        Image(systemName: "message")
                        Text("Unlimited questions")
                    }
                    HStack{
                        Image(systemName: "dollarsign.circle")
                        Text("Add up to 10 assets")
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
            .padding(.top, UIScreen.main.bounds.height * 0.045)
            Spacer()
            Group {
                Section {
                    ForEach(storeVM.subscriptions) { product in
                        Button(action: {
                            Task {
                                await buy(product: product)
                            }
                        }){
                            VStack {
                                
                                HStack {
                                    Spacer()
                                    Text("$14.99")
                                    Text("/")
                                    Text("Monthly")
                                    Spacer()
                                }
                                .font(.system(size: UIScreen.main.bounds.width * 0.1))
                                .bold()
                            }
                            .padding()
                            .padding(.vertical, 27)
                        }
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(45)
                        .padding(.horizontal)
                    }
                }
            }
            Button(action: {
                Task{
                    await storeVM.restoreProducts()
                }
            }){
                Text("Restore Purchases")
                    .underline()
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        //.environmentObject(StoreVM())
    }
    
    func buy(product: Product) async {
        do {
            try await storeVM.purchase(product)
            isPurchased = true
            await storeVM.updatePurchasedProducts()
            if storeVM.success{
                dismiss()
            }
        } catch {
            print("purchase failed")
        }
    }

}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .environmentObject(StoreVM())
    }
}
