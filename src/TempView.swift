//
//  TempView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/2/23.
//

import SwiftUI

struct TempView: View {
    let now = Date()
    var body: some View {
        VStack {
            Button {
                print(now)
            } label: {
                Text("Hello")
            }
            
        }
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
