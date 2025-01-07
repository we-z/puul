//
//  LogoView.swift
//  Stevely
//
//  Created by Wheezy Salem on 6/11/23.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            Color(.gray)
                .opacity(0.3)
            VStack {
                LinearGradient(
                    colors: [.primary.opacity(0.5), .primary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: 42, height: 90)
            .offset(x: -52.8, y: 114)
            Text("U")
                .rotationEffect(.degrees(-90))
                .offset(x: 10)
        }
        .fontWeight(.heavy)
        .bold()
        .font(.system(size: 240))
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
