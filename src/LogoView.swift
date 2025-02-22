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
            Color(.white)
//            Color(.white)
//                .opacity(0.15)
//                .ignoresSafeArea()
//            ZStack {
//                
//                VStack {
//                    LinearGradient(
//                        colors: [.black.opacity(0.5), .black],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                }
//                .frame(width: 42, height: 90)
//                .offset(x: -52.8, y: 114)
//                Text("U")
//                    .foregroundColor(.black)
//                    .rotationEffect(.degrees(-90))
//                    .offset(x: 10)
//            }
//            .offset(y: -45)
            Color(.black)
                .aspectRatio(contentMode: .fit)
            Text("Puul")
                .foregroundColor(.white)
                .bold()
                .font(.system(size: 150))
        }
//        .fontWeight(.heavy)
//        .bold()
//        .font(.system(size: 240))
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
