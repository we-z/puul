//
//  PlaidLinkFlowView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/2/23.
//

import Foundation
import LinkKit
import SwiftUI

public struct PlaidLinkFlow: View {
    @State var showLink: Bool
    @EnvironmentObject var model: AppModel
    var isBank: Bool

    @StateObject var pm: PlaidModel

    public var body: some View {
        if pm.linkToken.isEmpty {
            ProgressView()
        } else {
            let linkController = LinkController(
                configuration: .linkToken(createLinkTokenConfiguration())
            ) { createError in
                print("Link Creation Error: \(createError)")
                self.showLink = false
            }

            linkController
                .onOpenURL { url in
                    linkController.linkHandler?.resumeAfterTermination(from: url)
                }
        }
    }

    func createLinkTokenConfiguration() -> LinkTokenConfiguration {
        var configuration = LinkTokenConfiguration(
            token: pm.linkToken,
            onSuccess: { success in
                print("public-token: \(success.publicToken) metadata: \(success.metadata)")
                pm.exchangePublicToken(publicToken: success.publicToken) { result in
                    switch result {
                    case let .success(accessToken):
                        print("access_token: \(accessToken)")
                        DispatchQueue.main.async {
                            model.showingWarningAlert = true
                        }
                        if isBank == true {
                            DispatchQueue.main.async {
                                pm.bankAccessTokens.append(accessToken)
                                print("bankAccessTokens: \(pm.bankAccessTokens)")
                            }

                            pm.getBankData(accessToken: accessToken)
                        } else if isBank == false {
                            DispatchQueue.main.async {
                                pm.brokerAccessTokens.append(accessToken)
                                print("brokerAccessTokens: \(pm.brokerAccessTokens)")
                            }

                            pm.getBrokerAccount(accessToken: accessToken)
                        }
                    case let .failure(error):
                        print("Error exchanging public token: \(error)")
                    }
                }
                showLink = false
            }
        )

        configuration.onEvent = { event in
            print("Link Event: \(event)")
        }

        configuration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                print("exit with \(exit.metadata)")
            }
            pm.linkToken = ""
            pm.getSavedBankAccounts()
            pm.getBrokerAccounts()
            showLink = false
        }

        return configuration
    }
}
