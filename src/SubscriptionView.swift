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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            Capsule()
                .frame(maxWidth: 45, maxHeight: 9)
                .padding(.top, 9)
                .foregroundColor(.primary)
                .opacity(0.3)
            HStack {
                Text("🔓")
                    .font(.system(size: 60))
                    .padding(.leading)
                Text("Unlock all of\nPuuls features!")
                    .lineLimit(2)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: 39))
                    .bold()
                Spacer()
            }
            Divider()
                .overlay(.primary)
                .padding(.horizontal)
                .offset(y: -6)
            HStack{
                VStack(alignment: .leading, spacing: 36){
                    HStack{
                        Text("💬")
                            .scaleEffect(1.2)
                        Text("Ask Unlimited questions")
                            .underline()
                    }
                    HStack{
                        Text("💰")
                            .scaleEffect(1.2)
                        Text("Add unlimited assets")
                            .underline()
                    }
                    HStack{
                        Text("🏡")
                            .scaleEffect(1.2)
                        Text("Use Real Estate features")
                            .underline()
                    }
                }
                .bold()
                .italic()
                .font(.system(size: 24))
                .padding(.horizontal, 30)
                Spacer()
            }
            .padding(.bottom, 36)
            .padding(.top, 21)
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
                                .font(.system(size: 36))
                                .bold()
                            }
                            .padding(.vertical, 27)
                            
                        }
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(30)
                        .overlay( /// apply a rounded border
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.primary, lineWidth: 3)
                        )
                        .padding(.horizontal)
                    }
                }
            }
            Button(action: {
                Task{
                    try? await AppStore.sync()
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
