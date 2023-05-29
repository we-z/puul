//
//  PlaidAPI.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/2/23.
//

import Foundation
import LinkKit
import SwiftUI

public struct PlaidLinkFlow: View {
    @Binding var showLink: Bool
    @Binding var isBank: Bool
    
    @EnvironmentObject var pm: PlaidModel
    
    public var body: some View {
        if pm.linkToken.isEmpty{
            ProgressView()
                .onAppear{
                    if isBank == true {
                        pm.createBankLinkToken()
                    } else {
                        pm.createBrokerLinkToken()
                    }
                }
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
                showLink = false
                pm.exchangePublicToken(publicToken: success.publicToken) { result in
                    switch result {
                    case .success(let accessToken):
                        print("access_token: \(accessToken)")
                        if isBank == true {
                            pm.getBankAccount(accessToken: accessToken)
                        } else {
                            pm.getBrokerAccount(accessToken: accessToken)
                        }
                    case .failure(let error):
                        print("Error exchanging public token: \(error)")
                    }
                }
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
            showLink = false
            pm.getBankAccounts()
            pm.getBrokerAccounts()
        }
        

        return configuration
    }
}
