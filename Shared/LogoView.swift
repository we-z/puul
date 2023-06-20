//
//  LogoView.swift
//  Stevely
//
//  Created by Wheezy Salem on 6/11/23.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack{
            Color(.gray)
                .opacity(0.3)
            VStack{
                LinearGradient(
                    colors: [.gray, .primary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: 30, height: 120)
            .offset(x:-58.6, y:105)
            Text("U")
                .rotationEffect(.degrees(-90))
                .offset(x: 10)
                
        }
        .bold()
        .font(.system(size: 240))
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
