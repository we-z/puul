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
                .opacity(0.36)
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 240))
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
