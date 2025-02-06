//
//  RatingsView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 2/5/25.
//

import SwiftUI

struct RatingsView: View {
    var body: some View {
        VStack {
            Text("Puul Rating")
                .font(.largeTitle)
                .bold()
                .padding()
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    RatingsView()
}
