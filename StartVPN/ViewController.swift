//
//  ViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 12.03.2021.
//

import UIKit
import NetworkExtension
import NVActivityIndicatorView
import DropDown
import SwiftyStoreKit

class ViewController: UIViewController {

    @IBOutlet weak var uploadIcon: UIImageView!
    @IBOutlet weak var downloadIcon: UIImageView!
    @IBOutlet weak var uploadHeader: UILabel!
    @IBOutlet weak var downloadHeader: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var getImage: UIImageView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var getLabel: UILabel!
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .ballClipRotateMultiple, color: .white, padding: 0)
    let dropDown = DropDown()
    var timer = Timer()
    var statusConnection: Bool = false
    var flagCountry: Int = 0
    var indexMap: Int = 0
    let countiesArray = ["RANDOM COUNTRY", "USA", "CANADA", "GERMANY", "FRANCE", "POLAND"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        checkSubscription()
        addShadow()
        dropDownSetup()
        setupNVActivityIndicatorView()
        hidden()
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
           notification in
        
        let nevpnconn = notification.object as! NEVPNConnection
        let status = nevpnconn.status
        self.checkNEStatus(status: status)
        }
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = mapView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(1.0).cgColor]
        switch UIDevice.current.modelName {
        case "iPhone 12 Pro Max", "iPhone XS Max", "iPhone 11 Pro Max":
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.1)
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.85)
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)":
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.8)
        default:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        }
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.locations = [NSNumber(value: 0.1),NSNumber(value: 0.17),NSNumber(value: 0.24)]
        mapView.layer.mask = gradientLayer
        mapView.clipsToBounds = true
    }
    
    private func hidden() {
        uploadIcon.isHidden = true
        downloadIcon.isHidden = true
        uploadHeader.isHidden = true
        downloadHeader.isHidden = true
        uploadLabel.isHidden = true
        downloadLabel.isHidden = true
    }
    
    private func unhidden() {
        uploadIcon.isHidden = false
        downloadIcon.isHidden = false
        uploadHeader.isHidden = false
        downloadHeader.isHidden = false
        uploadLabel.isHidden = false
        downloadLabel.isHidden = false
    }
    
    private func getTrafficStats(){
        guard let session = manager?.connection as? NETunnelProviderSession else {
            return
        }
        do {
            try session.sendProviderMessage("SOME_STATIC_KEY".data(using: .utf8)!) { (data) in
            guard let data = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data! as Data) else {
                return
            }
                let bytesOut = data["bytesOut"] as? Int64 ?? 0
                let bytesIn = data["bytesIn"] as? Int64 ?? 0
                self.uploadLabel.text = Units(bytes: bytesOut).getReadableUnit()
                self.downloadLabel.text = Units(bytes: bytesIn).getReadableUnit()
    
        }

        } catch {
            print(error)
        }
    }
    
    private func mapAnimation(statusConnection: Bool) {
        var toImage = UIImage()
        var scale = CGAffineTransform()
        var translation = CGAffineTransform()
        var transform = CGAffineTransform()
        if statusConnection == true {
            switch indexMap {
            case 1,2:
                toImage = UIImage(named:"map_" + String(indexMap))!
                scale = CGAffineTransform(scaleX: 2, y: 2)
                translation = CGAffineTransform(translationX: 200, y: 80)
                transform = scale.concatenating(translation)
            case 3,4,5:
                toImage = UIImage(named:"map_" + String(indexMap))!
                scale = CGAffineTransform(scaleX: 6, y: 6)
                translation = CGAffineTransform(translationX: 0, y: 150)
                transform = scale.concatenating(translation)
            default:
                break
            }
        } else {
              toImage = UIImage(named:"map")!
              transform = .identity
        }
        UIView.transition(with: self.mapImage,
                          duration: 2.0,
                          options: .transitionCrossDissolve,
                          animations: {
                              self.mapImage.transform = transform
                              self.mapImage.image = toImage
                          },
                          completion: nil)
    }
    
    private func addShadow() {
        startButton.layer.shadowColor = UIColor(white: 0.6, alpha: 1).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        startButton.layer.shadowOpacity = 0.9
        startButton.layer.shadowRadius = 10.0
        startButton.layer.masksToBounds = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.connection.stopVPNTunnel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    @IBAction func showDropDown(_ sender: UIButton) {
        dropDown.show()
    }
    
    @IBAction func testPush(_ sender: UIButton) {
        self.goToPurchase()
    }
    
    
    @IBAction func establishVPNConnection(_ sender: UIButton) {
        if statusConnection == false {
            networkMonitor()
            let callback = { (error: Error?) -> Void in
                manager?.loadFromPreferences(completionHandler: { (error) in
                    guard error == nil else {
                        print("\(error!.localizedDescription)")
                        return
                    }
                    let options: [String : NSObject] = [
                        "username": "vpnbook" as NSString,
                        "password": "tvd23GH" as NSString
                    ]

                    if purchaseStatus > 0 {
                        do {
                            try manager?.connection.startVPNTunnel(options: options)
                        } catch {
                            print("\(error.localizedDescription)")
                        }
                    } else {
                        self.dropDownButton.isUserInteractionEnabled = false
                        self.startButton.isUserInteractionEnabled = false
                        self.startButton.setImage(UIImage(named: "Connect.png"), for: .normal)
                        self.startButton.pulsate(true)
                        self.loading.startAnimating()
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
                                        do {
                                            try manager?.connection.startVPNTunnel(options: options)
                                        } catch {
                                            print("\(error.localizedDescription)")
                                        }
                                        return
                                    case .expired(let expiryDate, let items):
                                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                                        if i == 2 && purchaseStatus == 0 {
                                            self.goToPurchase()
                                            self.dropDownButton.isUserInteractionEnabled = true
                                            self.startButton.isUserInteractionEnabled = true
                                            self.startButton.setImage(UIImage(named: "On.png"), for: .normal)
                                            self.startButton.pulsate(false)
                                            self.loading.stopAnimating()
                                        }
                                    case .notPurchased:
                                        print("The user has never purchased \(productId)")
                                        if i == 2 && purchaseStatus == 0 {
                                            self.goToPurchase()
                                            self.dropDownButton.isUserInteractionEnabled = true
                                            self.startButton.isUserInteractionEnabled = true
                                            self.startButton.setImage(UIImage(named: "On.png"), for: .normal)
                                            self.startButton.pulsate(false)
                                            self.loading.stopAnimating()
                                        }
                                    }
                                case .error(let error):
                                    print("Receipt verification failed: \(error)")
                                }
                            }
                        }
                    }
               })
            }
            configureVPN(flagCountry: flagCountry, callback: callback)
        } else {
            manager?.connection.stopVPNTunnel()
        }
    }
    
    private func setupNVActivityIndicatorView() {
        loading.translatesAutoresizingMaskIntoConstraints = false
        startButton.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.widthAnchor.constraint(equalTo: self.startButton.widthAnchor, constant: -20 ),
            loading.heightAnchor.constraint(equalTo: self.startButton.heightAnchor, constant: -20 ),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func checkNEStatus(status:NEVPNStatus) {
           switch status {
           case NEVPNStatus.invalid:
             self.statusLabel.text = "INVALID"
           case NEVPNStatus.disconnected:
             self.statusLabel.text = "DISCONNECTED"
             self.dropDownButton.isUserInteractionEnabled = true
             self.startButton.isUserInteractionEnabled = true
             statusConnection = false
             self.hidden()
             timer.invalidate()
             self.startButton.setImage(UIImage(named: "On.png"), for: .normal)
             self.startButton.pulsate(false)
             self.loading.stopAnimating()
           case NEVPNStatus.connecting:
             self.statusLabel.text = "CONNECTING"
             self.dropDownButton.isUserInteractionEnabled = false
             self.startButton.isUserInteractionEnabled = false
             self.startButton.setImage(UIImage(named: "Connect.png"), for: .normal)
             self.startButton.pulsate(true)
             self.loading.startAnimating()
           case NEVPNStatus.connected:
             self.statusLabel.text = "CONNECTED"
             self.startButton.isUserInteractionEnabled = true
             statusConnection = true
             self.startButton.pulsate(false)
             self.loading.stopAnimating()
             self.unhidden()
             self.startButton.setImage(UIImage(named: "Off.png"), for: .normal)
             timer.invalidate()
             timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdate), userInfo: Date(), repeats: true)
             mapAnimation(statusConnection: true)
           case NEVPNStatus.reasserting:
             self.statusLabel.text = "REASSERTING"
           case NEVPNStatus.disconnecting:
             self.statusLabel.text = "DISCONNECTING"
             mapAnimation(statusConnection: false)
           default:
             print("Unknown VPN connection status")
         }
    }
    
    @objc func timerUpdate() {
        let elapsed = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        let hours = Int(elapsed / 3600)
        let minutes = Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(elapsed.truncatingRemainder(dividingBy: 60))
        if hours < 1 {
            self.statusLabel.text =  "CONNECTED " + String(format: "%02d:%02d", minutes, seconds)
            getTrafficStats()
        } else {
            self.statusLabel.text =  "CONNECTED " + String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            getTrafficStats()
        }
    }
    
    private func goToPurchase() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Purchase")
        present(viewController, animated: true, completion: nil)
    }

    private func dropDownSetup() {
        vwDropDown.layer.cornerRadius = 10
        dropDown.anchorView = vwDropDown
        dropDown.dataSource = countiesArray
        let appearance = DropDown.appearance()
        appearance.cellHeight = 50
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .black
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.getImage.image = UIImage(named: "logo_\(index)")
            self.getLabel.text = item
            flagCountry = index
        }
        dropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MyCell else { return }
            cell.logoImageView.image = UIImage(named: "logo_\(index)")
        }
    }

}

