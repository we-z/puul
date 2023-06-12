//
//  ChatGPTAPI.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import Foundation

class ChatGPTAPI: @unchecked Sendable {
    
    private let appModel: AppModel
    private let plaidModel: PlaidModel
    private let systemMessage: Message
    private let temperature: Double
    private let model: String
    let prompt: String = "Your name is Steve. When I ask who or what are you, you reply with I'm Steve. You are an expert financial advisor specialized in giving personal Investing and Financial advice. You have helped people buy homes, send there kids to college, and achieve financial freedom. Your task is to give the best financial advice when it comes to finance. When I ask for help with choosing stocks and ETFs, you will reply with tickers of good stocks and ETFs. You will be provided with my bank account transactions and holdings in broker accounts. Advice me based on that information. do not answer anything other than investing and finance-related queries. You must always ask questions before you answer so you can better zone in on what I'm seeking. "
    
    let apiKey = "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"
    @Published var historyList = [Message]()
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
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
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private var headers: [String: String] {
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

    init(model: String = "gpt-3.5-turbo", temperature: Double = 0.5) {
        self.plaidModel = PlaidModel()
        self.appModel = AppModel()
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
    
    private func generateMessages(from text: String) -> [Message] {
        let networthMessage = [Message(role: "user", content: "My total networth is $" + plaidModel.totalNetWorth.withCommas()), Message(role: "assistant", content: "ok")]
        let riskMessage = [Message(role: "user", content: "My risk level is " + appModel.selectedRiskLevel), Message(role: "assistant", content: "ok")]
        let basicMessages = networthMessage + riskMessage
        let bankMessage = [Message(role: "user", content: plaidModel.bankString), Message(role: "assistant", content: "ok")]
        let brokerMessage = [Message(role: "user", content: plaidModel.brokerString), Message(role: "assistant", content: "ok")]
        let listMessages = bankMessage + brokerMessage
        
        var messages = [systemMessage] + listMessages + basicMessages + historyList + [Message(role: "user", content: text)]
        
        if messages.contentCount > (4000 * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        return messages
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model: model, temperature: temperature,
                              messages: generateMessages(from: text), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
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


