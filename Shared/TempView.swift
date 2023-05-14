//
//  TempView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/2/23.
//

import SwiftUI

struct TempView: View {
    @State var linkToken: String = ""
        
    func createLinkToken() {
        guard let url = URL(string: "https://sandbox.plaid.com/link/token/create") else {
            print("Invalid URL")
            return
        }
        
        let parameters = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "user": [
                "client_user_id": "unique-per-user"
            ],
            "client_name": "Puul",
            "products": ["auth"],
            "country_codes": ["US"],
            "language": "en",
            "redirect_uri": "https://cdn-testing.plaid.com/link/v2/stable/sandbox-oauth-a2a-redirect.html",
            "account_filters": [
                "depository": [
                    "account_subtypes": ["checking"]
                ]
            ]
        ] as [String : Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Invalid body parameters")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching linkToken: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let linkToken = json?["link_token"] as? String {
                        self.linkToken = linkToken
                        print("Link token: \(linkToken)")
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack {
            Button(action: {
                createLinkToken()
            }) {
                Text("Create Link Token")
            }
            Text("Link Token: \(linkToken)")
        }
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
