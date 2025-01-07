//
//  AppModel.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 6/2/23.
//

import Foundation
import SwiftUI
import UIKit

let isPurchasedKey = "IsPurchased"

class AppModel: ObservableObject {
    let lightModeKey: String = "lightmodeKey"
    let hapticKey: String = "hapticModeKey"
    let risklevelKey: String = "risklevelkey"
    let timeFrameKey: String = "timeframekey"
    @AppStorage(isPurchasedKey) var isPurchased: Bool = UserDefaults.standard.bool(forKey: isPurchasedKey)
    @Published var showingWarningAlert = false
    @Published var selectedRiskLevel = "" {
        didSet {
            saveRiskSetting()
        }
    }

    @Published var selectedTimeFrame = "" {
        didSet {
            saveTimeFrameSetting()
        }
    }

    @Published public var isLightMode: Bool = false {
        didSet {
            savelightSetting()
        }
    }

    @Published public var hapticModeOn: Bool = true {
        didSet {
            saveHapticSetting()
        }
    }

    func savelightSetting() {
        if let lightSetting = try? JSONEncoder().encode(isLightMode) {
            UserDefaults.standard.set(lightSetting, forKey: lightModeKey)
        }
    }

    func saveHapticSetting() {
        if let hapticSetting = try? JSONEncoder().encode(hapticModeOn) {
            UserDefaults.standard.set(hapticSetting, forKey: hapticKey)
        }
    }

    func saveRiskSetting() {
        if let riskSetting = try? JSONEncoder().encode(selectedRiskLevel) {
            UserDefaults.standard.set(riskSetting, forKey: risklevelKey)
        }
    }

    func saveTimeFrameSetting() {
        if let timeFramSetting = try? JSONEncoder().encode(selectedTimeFrame) {
            UserDefaults.standard.set(timeFramSetting, forKey: timeFrameKey)
        }
    }

    init() {
        getSettings()
    }

    func getSettings() {
        getLightSetting()
        getHapticSetting()
        getRiskSetting()
        getTimeFrameSetting()
    }

    func getLightSetting() {
        guard
            let lightData = UserDefaults.standard.data(forKey: lightModeKey),
            let savedLightSetting = try? JSONDecoder().decode(Bool.self, from: lightData)
        else { return }

        isLightMode = savedLightSetting
    }

    func getHapticSetting() {
        guard
            let hapticData = UserDefaults.standard.data(forKey: hapticKey),
            let savedHapticSetting = try? JSONDecoder().decode(Bool.self, from: hapticData)
        else { return }

        hapticModeOn = savedHapticSetting
    }

    func getRiskSetting() {
        guard
            let riskData = UserDefaults.standard.data(forKey: risklevelKey),
            let savedRiskSetting = try? JSONDecoder().decode(String.self, from: riskData)
        else { return }

        selectedRiskLevel = savedRiskSetting
    }

    func getTimeFrameSetting() {
        guard
            let timeFrameData = UserDefaults.standard.data(forKey: timeFrameKey),
            let savedTimeFrameSetting = try? JSONDecoder().decode(String.self, from: timeFrameData)
        else { return }

        selectedTimeFrame = savedTimeFrameSetting
    }
}

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.3 : 1.0)
            .onChange(of: configuration.isPressed) { isPressed in

                if isPressed {
//                    if model.hapticModeOn {
                        // Trigger haptic feedback
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred()
//                    }
                }
            }
    }
}
