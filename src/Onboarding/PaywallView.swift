//
//  PaywallView.swift
//  Hushpost
//
//  Created by Wheezy Capowdis on 1/1/25.
//

import SwiftUI

struct PaywallView: View {
    @State var done: Bool = false
    // Features of the private photo-sharing app and their respective icons
    let featuresWithIcons = [
        ("End-to-End Encryption", "lock.fill"),
        ("No Ads, No Tracking", "eye.slash.fill"),
        ("Private Group Sharing", "person.2.fill"),
        ("Anonymous Messaging", "message"),
        ("Self-Destructing Photos", "flame.fill"),
        ("Granular Privacy Controls", "slider.horizontal.3"),
        ("Password-Protection", "key.fill"),
        ("FaceID-Protection", "faceid"),
        ("Open Source Code", "chevron.left.slash.chevron.right"),
        ("Verified Secure Builds", "checkmark.shield.fill"),
        ("No Screenshots", "photo"),
        ("No Screenrecordings", "video.slash.fill"),
        ("Exclusive Membership", "crown.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    // Large SF Symbol icon
                    ZStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(120)
                            .padding()
                    }
                    
                    // Title
                    Text("Privacy is priceless")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Description
                    Text("Secure your most valuable memories. Explore and share photos privately.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Features
                    VStack {
                        ForEach(featuresWithIcons, id: \.0) { feature, icon in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                                    .padding(.trailing, 6)
                                Text(feature)
                                    .bold()
                                Spacer()
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 6)
                            }
                            .padding()
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(15)
                    .padding()
                }
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 12) {
                Divider()
                    .shadow(color: .black, radius: 0.3)
                Button {
                    withAnimation(.easeInOut) {
                        done = true
                    }
                } label: {
                    Text("Continue for free")
                        .bold()
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                        .colorInvert()
                        .background(Color.primary)
                        .cornerRadius(21)
                        .padding([.horizontal])
                }
                Text("1 month free trial, then $19.99 / month")
                    .font(.headline)
                Text("Restore Purchase | Terms | Privacy")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
//            .background(.white)
            
        }
//        .background(Color.blue.ignoresSafeArea())
        .offset(x: done ? -500 : 0)
    }
}

#Preview {
    PaywallView()
}
