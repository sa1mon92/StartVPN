//
//  VPNDataFetcher.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 09.06.2022.
//

import Foundation

final class VPNDataFetcher {
    
    static private let vpnProfileNames = ["USA": ["us1-udp53"]]
    
    private init() {}
    
    static func getDataFromVPNProfile(country: Country, networkProtocol: NetworkProtocol) -> Data? {
        if let countryProfiles = vpnProfileNames[country.rawValue] {
            let prefix = countryToPrefix(country: country)
            let suffix = networkProtocol.rawValue.lowercased()
            if let filename = countryProfiles.filter({ $0.hasPrefix(prefix) && $0.hasSuffix(suffix)}).randomElement(),
               let configurationFile = Bundle.main.url(forResource: filename, withExtension: "ovpn") {
                do {
                    let data = try Data(contentsOf: configurationFile)
                    return data
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
    static private func countryToPrefix(country: Country) -> String {
        var prefix: String
        switch country {
        case .random:
            prefix = ""
        case .USA:
            prefix = "us"
        }
        return prefix
    }
}
