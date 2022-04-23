//
//  SwiftyStoreKit.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 18.04.2021.
//

import UIKit
import SwiftyStoreKit

let purchaseId = ["com.sadyrev.StartVPN.weekly", "com.sadyrev.StartVPN.monthly", "com.sadyrev.StartVPN.yearly"]
let sharedSecret = "4b2b9f30be894b7aa64745301edb1e66"
var purchaseStatus: Int = 0

func checkSubscription() {
    purchaseStatus = 0
    for i in 0...purchaseId.count - 1 {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = purchaseId[i]
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    
                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    purchaseStatus = i + 1
                case .expired(let expiryDate, let items):
                    
                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    
                case .notPurchased:
                    
                        print("The user has never purchased \(productId)")
                    
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
}

