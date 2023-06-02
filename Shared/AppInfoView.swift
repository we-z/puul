//
//  AppInfoView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        VStack{
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
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView()
    }
}
