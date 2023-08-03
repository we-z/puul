//
//  SearchPropertiesView.swift
//  Puul
//
//  Created by Wheezy Salem on 8/2/23.
//

import SwiftUI

struct SearchPropertiesView: View {
    @State var searchText = ""
    @EnvironmentObject public var zillow: ZillowAPI
    
    private func convertToPercentEncoding(_ input: String) -> String {
        let allowedCharacterSet = CharacterSet.alphanumerics
        return input.reduce("") { result, char in
            if allowedCharacterSet.contains(char.unicodeScalars.first!) {
                return result + String(char)
            } else {
                return result + "%20"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.clear
                    .navigationTitle("Find Your Property")
                if !searchText.isEmpty {
                    Text("Searching for \(convertToPercentEncoding(searchText))")
                }
            }
            .onChange(of: searchText) { newText in
                zillow.getPropertiesByLocation(location: convertToPercentEncoding(searchText))
            }
        }
        .searchable(text: $searchText)
        .accentColor(.primary)
    }
}

struct SearjchPropertiesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPropertiesView()
            .environmentObject(ZillowAPI())
    }
}
