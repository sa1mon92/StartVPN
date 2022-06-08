//
//  ConnectWorker.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import NetworkExtension
import Network

class ConnectService {
    
    weak var interactor: ConnectInteractor!
    var selectedCountry: Country = .random
    
    private var connectingStatus: NEVPNStatus = .disconnected
    private var manager: NETunnelProviderManager?
    private var selectedCountryIndex: Int {
        return Country.allCases.firstIndex(where: { $0 ==  selectedCountry }) ?? 0
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: self , queue: nil) { [weak self] notification in
            
            let nevpnconn = notification.object as! NEVPNConnection
            let status = nevpnconn.status
            self?.checkNEStatus(status: status)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func checkNEStatus(status:NEVPNStatus) {
        
        connectingStatus = status
        
        switch status {
        case NEVPNStatus.invalid:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .invalid))
        case NEVPNStatus.disconnected:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .disconnected))
        case NEVPNStatus.connecting:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .connecting))
        case NEVPNStatus.connected:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .connected))
        case NEVPNStatus.reasserting:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .reasserting))
        case NEVPNStatus.disconnecting:
            interactor.makeRequest(request: .didChangeConnectingStatus(status: .disconnecting))
        default:
            break
        }
    }
    
    private func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    self?.interactor.makeRequest(request: .showError(title: "No Internet Connection", message: "Please check your internet connection and retry"))
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func startConnecting() {
        
        guard connectingStatus != .connected else {
            manager?.connection.stopVPNTunnel()
            return
        }
        guard let password = UserDefaults.standard.object(forKey: "password") as? String else {
            return
        }
        checkInternetConnection()
        
        let callback = { [weak self] (error: Error?) -> Void in
            
            self?.manager?.loadFromPreferences(completionHandler: { (error) in
                guard error == nil else {
                    print("\(error!.localizedDescription)")
                    return
                }
                let options: [String : NSObject] = [
                    "username": "vpnbook" as NSString,
                    "password": password as NSString
                ]
                do {
                    try self?.manager?.connection.startVPNTunnel(options: options)
                } catch {
                    print("\(error.localizedDescription)")
                }
           })
        }
        self.configureVPN(callback: callback)
    }
    
    private func configureVPN(callback: @escaping (Error?) -> Void) {
        
        let index = selectedCountryIndex == 0 ? Int.random(in: 1..<6) : selectedCountryIndex
        
        let configurationFile = Bundle.main.url(forResource: "vpn_\(index)", withExtension: "ovpn")
        let configurationContent = try! Data(contentsOf: configurationFile!)
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard error == nil else {
                print("\(error!.localizedDescription)")
                callback(error)
                return
            }
            
            self?.manager = managers?.first ?? NETunnelProviderManager()
            self?.manager?.loadFromPreferences(completionHandler: { (error) in
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
                
                self?.manager?.protocolConfiguration = tunnelProtocol
                self?.manager?.localizedDescription = "StartVPN"
                self?.manager?.isEnabled = true
                self?.manager?.saveToPreferences(completionHandler: { (error) in
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
}
