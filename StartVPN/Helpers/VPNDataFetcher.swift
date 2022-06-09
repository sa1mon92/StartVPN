//
//  VPNDataFetcher.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 09.06.2022.
//

import Foundation

final class VPNDataFetcher {
    
    static private let vpnProfileNames = ["POLAND": ["pl-tcp80",
                                              "pl-tcp443",
                                              "pl-udp53",
                                              "pl-udp25000"],
                                   "GERMANY": ["de-tcp443",
                                               "de-tcp80",
                                               "de-udp53",
                                               "de-udp25000"],
                                   "USA": ["us1-tcp80",
                                           "us1-tcp443",
                                           "us1-udp53",
                                           "us1-udp25000",
                                           "us2-tcp80",
                                           "us2-tcp443",
                                           "us2-udp53",
                                           "us2-udp25000"],
                                   "CANADA": ["ca1-udp25000",
                                              "ca1-udp53",
                                              "ca1-tcp443",
                                              "ca1-tcp80",
                                              "ca2-tcp80",
                                              "ca2-udp53",
                                              "ca2-udp25000"],
                                   "FRANCE": ["fr1-udp25000",
                                              "fr1-tcp80",
                                              "fr1-udp53",
                                              "fr2-tcp80",
                                              "fr2-tcp443",
                                              "fr2-udp53",
                                              "fr2-udp25000"]]
    
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
        case .Canada:
            prefix = "ca"
        case .Germany:
            prefix = "de"
        case .France:
            prefix = "fr"
        case .Poland:
            prefix = "pl"
        }
        return prefix
    }
}
