//
//  VertexAPI.swift
//  Puul
//
//  Created by Wheezy Salem on 8/3/23.
//

import Foundation
import SwiftUI

class VertexAPI: ObservableObject {
    @Published var historyList = [Message]()
    func fetchResponse(from userMessage: String) {
        let urlString = "https://us-central1-aiplatform.googleapis.com/v1/projects/puul-app/locations/us-central1/publishers/google/models/chat-bison@001:predict"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }

        let messages: [[String: Any]] = [
            [
                "author": "user",
                "content": "Hello"
            ],
            [
                "author": "bot",
                "content": "Hello there! How can I help you today?",
                "citationMetadata": [
                    "citations": []
                ]
            ],
            [
                "author": "user",
                "content": "what's your name"
            ],
            [
                "author": "bot",
                "content": "My name is Edward.",
                "citationMetadata": [
                    "citations": []
                ]
            ],
            [
                "author": "user",
                "content": "how old is planet earth?"
            ]
        ]

        let parameters: [String: Any] = [
            "instances": [
                [
                    "context": "Your name is Edward\n",
                    "examples": [],
                    "messages": userMessage
                ]
            ],
            "parameters": [
                "temperature": 0.2,
                "maxOutputTokens": 256,
                "topP": 0.8,
                "topK": 40
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer ya29.a0AfB_byB8B6Dj2togus1WOoBhaQUBH44i_o07r7Rriu9nEpTlLy4fqcdR0hAN2OGYXK8D2nbtKnCeziBkQMpNcA0PxPZJIs6yqD6ywlNyvNGihhPSoBhSp-Wak5iuOexc6ZgfVmLCxdsdHJ35QEoFXpVHttgTSVN9MTC9NwaCgYKAQ0SARISFQHsvYlskbv7EqqbuKnVjWcmKl_r7Q0173", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                if let data = data {
                    // Process the response data here
                    print("Response Data: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}

