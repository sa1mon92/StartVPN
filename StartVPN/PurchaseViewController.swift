//
//  PurchaseViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 13.04.2021.
//

import UIKit
import SwiftyStoreKit
import Network

class PurchaseViewController: UIViewController {

    @IBOutlet weak var startPurchase: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var textWeekly: UILabel!
    @IBOutlet weak var textWeeklyPrice: UILabel!
    @IBOutlet weak var textMouthly: UILabel!
    @IBOutlet weak var textMouthlyPrice: UILabel!
    @IBOutlet weak var textYearly: UILabel!
    @IBOutlet weak var textYearlyPrice: UILabel!
    @IBOutlet weak var stackViewPurchase: UIStackView!
    @IBOutlet weak var buttonTerms: UIButton!
    @IBOutlet weak var buttonPolicy: UIButton!
    @IBOutlet weak var buttonExit: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var imageSave: UIImageView!
    @IBOutlet weak var stackViewIcons: UIStackView!
    @IBOutlet weak var labelChoose: UILabel!
    @IBOutlet weak var restorePurchases: UIButton!
    
    let colorGreen: UIColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.2274509804, alpha: 1)
    let colorWhite: UIColor = .white
    let colorSteel: UIColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    let colorMagnesium: UIColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
    var plainId = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addShadow()
        self.addStyle()
        //checkSubscription()
    }

    @IBAction func startPurchase(_ sender: UIButton) {
        networkMonitor()
        if purchaseStatus > 0 {
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
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Subscription status", message: "Your subscription is active until \(expiryDate)\n")
                                }
                                print("\(productId) is valid until \(expiryDate)\n\(items)\n")
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
        } else {
            SwiftyStoreKit.purchaseProduct(purchaseId[plainId], quantity: 1, atomically: true) { result in
                switch result {
                case .success(let purchase):
                    print("Purchase Success: \(purchase.productId)")
                    self.dismiss(animated: true, completion: nil)
                    checkSubscription()
                case .error(let error):
                    switch error.code {
                    case .unknown: print("Unknown error. Please contact support")
                    case .clientInvalid: print("Not allowed to make the payment")
                    case .paymentCancelled: break
                    case .paymentInvalid: print("The purchase identifier was invalid")
                    case .paymentNotAllowed: print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable: print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                    case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                    default: print((error as NSError).localizedDescription)
                    }
                }
            }
        }
        
    }
    
    @IBAction func buttonPolicy(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Policy")
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonTerms(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Terms")
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func restPurchases(_ sender: UIButton) {
        networkMonitor()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    @IBAction func leftButton(_ sender: UIButton) {
        leftView.layer.borderColor = colorGreen.cgColor
        centerView.layer.borderColor = colorWhite.cgColor
        rightView.layer.borderColor = colorWhite.cgColor
        leftView.layer.backgroundColor = colorWhite.cgColor
        centerView.layer.backgroundColor = colorMagnesium.cgColor
        rightView.layer.backgroundColor = colorMagnesium.cgColor
        textWeekly.textColor = .black
        textWeeklyPrice.textColor = .black
        textMouthly.textColor = colorSteel
        textMouthlyPrice.textColor = colorSteel
        textYearly.textColor = colorSteel
        textYearlyPrice.textColor = colorSteel
        imageSave.isHidden = true
        plainId = 0
    }
    
    @IBAction func centerButton(_ sender: UIButton) {
        leftView.layer.borderColor = colorWhite.cgColor
        centerView.layer.borderColor = colorGreen.cgColor
        rightView.layer.borderColor = colorWhite.cgColor
        leftView.layer.backgroundColor = colorMagnesium.cgColor
        centerView.layer.backgroundColor = colorWhite.cgColor
        rightView.layer.backgroundColor = colorMagnesium.cgColor
        textWeekly.textColor = colorSteel
        textWeeklyPrice.textColor = colorSteel
        textMouthly.textColor = .black
        textMouthlyPrice.textColor = .black
        textYearly.textColor = colorSteel
        textYearlyPrice.textColor = colorSteel
        imageSave.isHidden = true
        plainId = 1
    }
    
    @IBAction func buttonExit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightButton(_ sender: UIButton) {
        leftView.layer.borderColor = colorWhite.cgColor
        centerView.layer.borderColor = colorWhite.cgColor
        rightView.layer.borderColor = colorGreen.cgColor
        leftView.layer.backgroundColor = colorMagnesium.cgColor
        centerView.layer.backgroundColor = colorMagnesium.cgColor
        rightView.layer.backgroundColor = colorWhite.cgColor
        textWeekly.textColor = colorSteel
        textWeeklyPrice.textColor = colorSteel
        textMouthly.textColor = colorSteel
        textMouthlyPrice.textColor = colorSteel
        textYearly.textColor = .black
        textYearlyPrice.textColor = .black
        imageSave.isHidden = false
        plainId = 2
    }
    
    private func showAlert(title: String, message: String) {
             let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
             let action = UIAlertAction (title: "OK", style: .cancel, handler: nil)
             alert.addAction(action)
             DispatchQueue.main.async {
                 self.present(alert, animated: true, completion: nil)
             }
    }
    
    private func addStyle() {
        leftView.layer.backgroundColor = colorMagnesium.cgColor
        centerView.layer.backgroundColor = colorMagnesium.cgColor
        rightView.layer.backgroundColor = colorWhite.cgColor
        startPurchase.layer.cornerRadius = 10
        leftView.addBorderAndColor(color: colorWhite, width: 3.0, corner_radius: 10, clipsToBounds: true)
        centerView.addBorderAndColor(color: colorWhite, width: 3.0, corner_radius: 10, clipsToBounds: true)
        rightView.addBorderAndColor(color: colorGreen, width: 3.0, corner_radius: 10, clipsToBounds: true)
        textWeekly.textColor = colorSteel
        textWeeklyPrice.textColor = colorSteel
        textMouthly.textColor = colorSteel
        textMouthlyPrice.textColor = colorSteel
        textYearly.textColor = .black
        textYearlyPrice.textColor = .black
        textView.backgroundColor = .white
        imageSave.isHidden = false
    }
    
    private func addShadow() {
        startPurchase.layer.shadowColor = UIColor(white: 0.6, alpha: 1).cgColor
        startPurchase.layer.shadowOffset = CGSize(width: 0, height: 3)
        startPurchase.layer.shadowOpacity = 0.9
        startPurchase.layer.shadowRadius = 10.0
        startPurchase.layer.masksToBounds = false
    }
    
    func networkMonitor() {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status == .unsatisfied {
                    DispatchQueue.main.async {
                        self.showAlert(title: "No Internet Connection", message: "Please check your internet connection and retry")
                    }
                }
            }
            let queue = DispatchQueue(label: "Network")
            monitor.start(queue: queue)
        }
    
    override func updateViewConstraints() {
           let heightButtons = self.startPurchase.frame.height + self.restorePurchases.frame.height + self.buttonPolicy.frame.height
           let heightStackViews = self.stackViewPurchase.frame.height + self.stackViewIcons.frame.height
        
           self.view.frame.size.height = heightButtons + heightStackViews + self.textView.frame.height + 200
           self.view.frame.origin.y =  UIScreen.main.bounds.height - (heightButtons + heightStackViews + self.textView.frame.height + 200)
           self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
           super.updateViewConstraints()
    }
}

extension UIView {
    func addBorderAndColor(color: UIColor, width: CGFloat, corner_radius: CGFloat = 0, clipsToBounds: Bool = false) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = corner_radius
        self.clipsToBounds = clipsToBounds
    }
}

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
       let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       layer.mask = mask
   }
}
