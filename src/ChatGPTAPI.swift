//
//  ChatGPTAPI.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import Foundation
import SwiftUI

class ChatGPTAPI: @unchecked Sendable {
    @StateObject var appModel = AppModel()
    @StateObject var plaidModel = PlaidModel()
    let systemMessage: Message
    let temperature: Double
    let model: String
    let prompt: String = "Your name is Steve, and you identify yourself as Steve when asked who or what you are. You possess expertise as a financial advisor specializing in personal investing and financial advice. You are part of Puul, a portfolio management platform that conveniently consolidates all my financial institutions, allowing me to view my entire portfolio in one place. Your primary responsibility is to provide exceptional financial advice within the realm of finance. Never respond with step-by-step guide or a list of instructions. If I seek assistance in selecting stocks and ETFs, you will offer ticker symbols for good stocks and ETFs, focusing solely on factual information. In case I pose a question without providing sufficient context, please suggest going back to the home page and adding a financial institution to offer you more details. Never respond with the phrase 'as an AI language model' to any question. Be opinionated in your responses. strive for varied sentence structures and rephrasing to maintain a natural flow in our conversation. To guide your advice, you will receive information about my bank account transactions and holdings in broker accounts, conveyed in natural language. This information is parsed from financial institutions linked via Plaid. Remember, your responses should solely address investing and finance-related inquiries, and it is important to ask clarifying questions before providing answers to better understand my specific needs.\n"
    var promptAndUserInfo: String = ""
    let apiKey = "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"
    @Published var historyList = [Message]()
    let urlSession = URLSession.shared
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "YYYY-MM-dd"
            return df
    }()
    
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    func saveHistoryList() {
        do {
            let data = try JSONEncoder().encode(historyList)
            UserDefaults.standard.set(data, forKey: "historyList")
        } catch {
            print("Error saving history list: \(error.localizedDescription)")
        }
    }

    init(model: String = "gpt-3.5-turbo-16k", temperature: Double = 0.5) {
        self.model = model
        self.systemMessage = .init(role: "system", content: prompt)
        self.temperature = temperature
        
        if let data = UserDefaults.standard.data(forKey: "historyList") {
            do {
                self.historyList = try JSONDecoder().decode([Message].self, from: data)
            } catch {
                print("Error loading history list: \(error.localizedDescription)")
            }
        }
    }
    
    public func generateMessages(from text: String, plaidModel: PlaidModel, appModel: AppModel) -> [Message] {
        
        promptAndUserInfo = prompt
        promptAndUserInfo += "My total networth is $" + plaidModel.totalNetWorth.withCommas() + ". "
        promptAndUserInfo += "My risk level is " + appModel.selectedRiskLevel + ". "
        promptAndUserInfo += "I want to invest " + appModel.selectedTimeFrame + ". "
        promptAndUserInfo += plaidModel.bankString
        promptAndUserInfo += plaidModel.brokerString
        
        var messages = [Message(role: "system", content: promptAndUserInfo)] + historyList + [Message(role: "user", content: text)]
        
        if messages.contentCount > (4000 * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text, plaidModel: PlaidModel(), appModel: AppModel())
        }
        return messages
    }
    
    public func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model: model, temperature: temperature,
                              messages: generateMessages(from: text, plaidModel: PlaidModel(), appModel: AppModel()), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
        saveHistoryList()
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}


