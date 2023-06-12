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
            Image(systemName: "message")
                .font(.system(size: 240))
            Text("$")
                .font(.system(size: 120))
                .offset(y: -18)
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
