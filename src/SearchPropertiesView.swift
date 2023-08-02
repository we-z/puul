//
//  SearchPropertiesView.swift
//  Puul
//
//  Created by Wheezy Salem on 8/2/23.
//

import SwiftUI

struct SearchPropertiesView: View {
    @State var searchText = ""
    @EnvironmentObject public var model: AppModel
    var body: some View {
        NavigationStack {
            ZStack{
                Color.clear
                    .navigationTitle("Find Your Property")
                if !searchText.isEmpty {
                    Text("Searching for \(searchText)")
                }
            }
        }
        .searchable(text: $searchText)
        .accentColor(.primary)
    }
}

struct SearchPropertiesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPropertiesView()
    }
}
