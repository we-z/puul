//
//  CloudKit.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/1/23.
//

import CloudKit
import Foundation

//
// let container = CKContainer.default()
// let publicDatabase = container.publicCloudDatabase
//
// public func generateLinkToken(completionHandler: @escaping (Result<String, Error>) -> Void) {
//    // Set up the request parameters
//    let url = URL(string: "https://sandbox.plaid.com/link/token/create")!
//    let clientId = "63d411aa2bcbe80013f42ad7"
//    let secret = "eaeb3902e92ac2fb678511ee863160"
//    let clientUserId = "unique-per-user"
//    let clientName = "Puul"
//    let products = ["auth"]
//    let countryCodes = ["US"]
//    let language = "en"
//    let redirectUri = "https://cdn-testing.plaid.com/link/v2/stable/sandbox-oauth-a2a-redirect.html"
//    let accountFilters = [
//        "depository": [
//            "account_subtypes": ["checking"]
//        ]
//    ]
//    let requestData: [String: Any] = [
//        "client_id": clientId,
//        "secret": secret,
//        "user": [
//            "client_user_id": clientUserId
//        ],
//        "client_name": clientName,
//        "products": products,
//        "country_codes": countryCodes,
//        "language": language,
//        "redirect_uri": redirectUri,
//        "account_filters": accountFilters
//    ]
//    let jsonData = try! JSONSerialization.data(withJSONObject: requestData)
//
//    // Set up the request
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.httpBody = jsonData
//
//    // Send the request
//    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//        if let error = error {
//            completionHandler(.failure(error))
//        } else if let data = data {
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                if let linkToken = jsonResponse["link_token"] as? String {
//                    // Do something with the link token
//                    completionHandler(.success(linkToken))
//                }
//            } catch {
//                completionHandler(.failure(error))
//            }
//        } else {
//            completionHandler(.failure(NSError(domain: "it did not work", code: 0, userInfo: nil)))
//        }
//    }
//    task.resume()
// }
