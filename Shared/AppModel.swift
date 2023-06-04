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
    @Published public var isLightMode: Bool = false
    @Published public var hapticModeOn: Bool = true
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

