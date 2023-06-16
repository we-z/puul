//
//  ViewModel.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import Foundation
import SwiftUI
import AVKit

class ChatViewModel: ObservableObject {
    
    @Published var isInteractingWithChatGPT = false
    @Published var messages: [MessageRow] = []
    @Published var inputMessage: String = ""
    let messagesSentTodayKey = "messagesSentTodayKey"
    @Published var messagesSentToday: Int = 0 {
        didSet {
            saveMessagesSentToday()
        }
    }
    
    func saveMessagesSentToday(){
        if let messagesSentTodayData = try? JSONEncoder().encode(messagesSentToday){
            UserDefaults.standard.set(messagesSentTodayData, forKey: messagesSentTodayKey)
        }
    }
    
    private let messagesKey = "messages"

    @MainActor
    func saveMessages() {
        let data = try? JSONEncoder().encode(messages)
        UserDefaults.standard.set(data, forKey: messagesKey)
    }
    
    #if !os(watchOS)
    private var synthesizer: AVSpeechSynthesizer?
    #endif
    
    private let api: ChatGPTAPI
    
    init(api: ChatGPTAPI, enableSpeech: Bool = false) {
        self.api = api
        
        getMessagesSentToday()
        
        if let date = UserDefaults.standard.object(forKey: "savedTime") as? Date {
           if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff >= 24 {
               messagesSentToday = 0
           }
        }
        
        if let meesageData = UserDefaults.standard.data(forKey: messagesKey),
           let messages = try? JSONDecoder().decode([MessageRow].self, from: meesageData) {
            self.messages = messages
        }
    }
    
    func getMessagesSentToday(){
        guard
            let messagesSentTodayData = UserDefaults.standard.data(forKey: messagesSentTodayKey),
            let savedMessagesSentToday = try? JSONDecoder().decode(Int.self, from: messagesSentTodayData)
        else {return}
        
        self.messagesSentToday = savedMessagesSentToday
    }
    
    @MainActor
    func sendTapped() async {
        let text = inputMessage
        inputMessage = ""
        await send(text: text)
    }
    
    @MainActor
    func clearMessages() {
        stopSpeaking()
        api.deleteHistoryList()
        UserDefaults.standard.removeObject(forKey: "messages")
        UserDefaults.standard.removeObject(forKey: "historyList")
        self.messages = []
    }
    
    @MainActor
    func retry(message: MessageRow) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }
        self.messages.remove(at: index)
        await send(text: message.sendText)
    }
    
    @MainActor
    private func send(text: String) async {
        isInteractingWithChatGPT = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true,
            sendImage: "person",
            sendText: text,
            responseImage: "circle",
            responseText: streamText,
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        speakLastResponse()
        saveMessages()
        messagesSentToday += 1
        UserDefaults.standard.set(Date(), forKey:"savedTime")
    }
    
    func speakLastResponse() {
        #if !os(watchOS)
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance )
        #endif
    }
    
    func stopSpeaking() {
        #if !os(watchOS)
        synthesizer?.stopSpeaking(at: .immediate)
        #endif
    }
    
}
