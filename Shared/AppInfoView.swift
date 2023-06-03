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
        VStack{
            HStack{
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                }
                .accentColor(.primary)
                Spacer()
                Text("Data Info")
                    
                Spacer()
                Text("     ")
            }
            .bold()
            .font(.system(size: 21))
            .padding()
            HStack{
                Text("Where is my financial data?")
                    .font(.system(size: UIScreen.main.bounds.width * 0.1))
                    .bold()
                Spacer()
            }
            .padding()
            HStack{
                Text("All of your financial data lives on your device and is only accesible to you. You may feel free to remove any of your assets by swiping to the left on them")
                    .font(.system(size: UIScreen.main.bounds.width * 0.06))
                    .multilineTextAlignment(.leading)
                    .italic()
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
