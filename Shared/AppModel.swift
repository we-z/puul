//
//  AppModel.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import Foundation
import SwiftUI
import UIKit

private func hapticFeedbackImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

class AppModel: ObservableObject {
    let lightModeKey: String = "bankaccounts"
    let hapticKey: String = "brokeraccounts"
    @Published public var isLightMode: Bool = false {
        didSet{
            saveSettings()
        }
    }
    @Published public var hapticModeOn: Bool = true {
        didSet{
            saveSettings()
        }
    }
    
    func saveSettings() {
        if let lightSetting = try? JSONEncoder().encode(isLightMode){
            UserDefaults.standard.set(lightSetting, forKey: lightModeKey)
        }
        if let hapticSetting = try? JSONEncoder().encode(hapticModeOn){
            UserDefaults.standard.set(hapticSetting, forKey: hapticKey)
        }
    }
    
    init() {
        getSettings()
    }
    
    func getSettings(){
        guard
            let lightData = UserDefaults.standard.data(forKey: lightModeKey),
            let savedLightSetting = try? JSONDecoder().decode(Bool.self, from: lightData)
        else {return}
        
        self.isLightMode = savedLightSetting
        
        guard
            let hapticData = UserDefaults.standard.data(forKey: hapticKey),
            let savedHapticSetting = try? JSONDecoder().decode(Bool.self, from: hapticData)
        else {return}
        
        self.hapticModeOn = savedHapticSetting
        
    }
}


enum Haptic {
    static func heavy() {
        hapticFeedbackImpact(style: .heavy)
    }
    static func light() {
        hapticFeedbackImpact(style: .light)
    }
}

struct HapticButtonStyle: ButtonStyle {
    @EnvironmentObject public var model: AppModel
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { isPressed in
                
                    if isPressed {
                        if model.hapticModeOn{
                        // Trigger haptic feedback
                        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred()
                    }
            }
        }
    }
}

