//
//  extensionViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 12.03.2021.
//

import UIKit
import NetworkExtension
import Network

var manager: NETunnelProviderManager?

extension ViewController {
    
    func configureVPN(flagCountry: Int, callback: @escaping (Error?) -> Void) {
        var flag: Int
         
        if flagCountry == 0 {
            flag = Int.random(in: 1..<6)
            indexMap = flag
        } else {
            flag = flagCountry
            indexMap = flagCountry
        }
        
        let configurationFile = Bundle.main.url(forResource: "vpn_" + String(flag), withExtension: "ovpn")
        let configurationContent = try! Data(contentsOf: configurationFile!)
        
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                callback(error)
                return
            }
            
            manager = managers?.first ?? NETunnelProviderManager()
            manager?.loadFromPreferences(completionHandler: { (error) in
                guard error == nil else {
                    print("\(error!.localizedDescription)")
                    callback(error)
                    return
                }
                
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.serverAddress = "vpnbook.org"
                tunnelProtocol.providerBundleIdentifier = "com.sadyrev.StartVPN.tunnel"
                tunnelProtocol.providerConfiguration = ["configuration": configurationContent]
                tunnelProtocol.disconnectOnSleep = false
                
                manager?.protocolConfiguration = tunnelProtocol
                manager?.localizedDescription = "StartVPN"
                manager?.isEnabled = true
                manager?.saveToPreferences(completionHandler: { (error) in
                    guard error == nil else {
                        print("\(error!.localizedDescription)")
                        callback(error)
                        return
                    }
                    
                    callback(nil)
                })
            })
        }
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
    
    func showAlert(title: String, message: String) {
            let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction (title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
   }
}
