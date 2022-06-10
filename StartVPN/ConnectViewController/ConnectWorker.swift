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
    var networkProtocol: NetworkProtocol = .TCP
    var selectedCountry: Country = .random {
        didSet {
            if selectedCountry != oldValue && oldValue != .random {
                stopConnecting()
            }
        }
    }
    
    private var timer = Timer()
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
            break
        case NEVPNStatus.disconnected:
            interactor.makeRequest(request: .statusChangedToDisconnected)
            interactor.makeRequest(request: .showMap(index: nil))
        case NEVPNStatus.connecting:
            interactor.makeRequest(request: .statusChangedToConnecting)
        case NEVPNStatus.connected:
            interactor.makeRequest(request: .statusChangedToConnected)
            interactor.makeRequest(request: .showMap(index: selectedCountryIndex))
            startTimer()
        case NEVPNStatus.reasserting:
            break
        case NEVPNStatus.disconnecting:
            break
        default:
            break
        }
    }
    
    private func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdate), userInfo: Date(), repeats: true)
    }
    
    @objc func timerUpdate() {
        let elapsed = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        let hours = Int(elapsed / 3600)
        let minutes = Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(elapsed.truncatingRemainder(dividingBy: 60))
        if hours < 1 {
            interactor.makeRequest(request: .updateTimer(timer: String(format: "%02d:%02d", minutes, seconds)))
            getTrafficStats()
        } else {
            interactor.makeRequest(request: .updateTimer(timer: String(format: "%02d:%02d:%02d", hours, minutes, seconds)))
            getTrafficStats()
        }
    }
    
    private func getTrafficStats(){
        guard let session = manager?.connection as? NETunnelProviderSession else { return }
        do {
            try session.sendProviderMessage("SOME_STATIC_KEY".data(using: .utf8)!) { [weak self] data in
                guard let data = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data! as Data) else { return }
                let bytesOut = data["bytesOut"] as? Int64 ?? 0
                let bytesIn = data["bytesIn"] as? Int64 ?? 0
                self?.interactor.makeRequest(request: .updateTrafficStats(upload: bytesOut, download: bytesIn))
            }
        } catch {
            print(error)
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
    
    func stopConnecting() {
        manager?.connection.stopVPNTunnel()
    }
    
    func startConnecting() {
        
        guard connectingStatus != .connected else {
            manager?.connection.stopVPNTunnel()
            return
        }
        guard let password = UserDefaults.standard.object(forKey: "password") as? String else {
            interactor.makeRequest(request: .showPasswordAlert)
            return
        }
        checkInternetConnection()
        
        let callback = { [weak self] (error: Error?) -> Void in
            
            self?.manager?.loadFromPreferences(completionHandler: { error in
                if let error = error {
                    self?.interactor.makeRequest(request: .showError(title: "Error", message: error.localizedDescription))
                    return
                }
                let options: [String : NSObject] = [
                    "username": "vpnbook" as NSString,
                    "password": password as NSString
                ]
                do {
                    try self?.manager?.connection.startVPNTunnel(options: options)
                } catch {
                    self?.interactor.makeRequest(request: .showPasswordAlert)
                }
           })
        }
        self.configureVPN(callback: callback)
    }
    
    private func configureVPN(callback: @escaping (Error?) -> Void) {
                
        if selectedCountry == .random {
            selectedCountry = Country[Int.random(in: 1..<6)]
            interactor.makeRequest(request: .didSelectCountry(country: selectedCountry))
        }
        
        guard let configurationContent = VPNDataFetcher.getDataFromVPNProfile(country: selectedCountry, networkProtocol: networkProtocol) else { return }
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error = error {
                self?.interactor.makeRequest(request: .showError(title: "Error", message: error.localizedDescription))
                callback(error)
                return
            }
            
            self?.manager = managers?.first ?? NETunnelProviderManager()
            self?.manager?.loadFromPreferences(completionHandler: { error in
                if let error = error {
                    self?.interactor.makeRequest(request: .showError(title: "Error", message: error.localizedDescription))
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
                self?.manager?.saveToPreferences(completionHandler: { error in
                    if let error = error {
                        self?.interactor.makeRequest(request: .showError(title: "Error", message: error.localizedDescription))
                        callback(error)
                        return
                    }
                    callback(nil)
                })
            })
        }
    }
}
