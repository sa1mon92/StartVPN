//
//  ConnectModels.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Connect {
    
    enum Model {
        struct Request {
            enum RequestType {
                case startButtonTouch
                case countryButtonTouch
                case didSelectCountry(country: Country)
                case showError(title: String, message: String)
                case showPasswordAlert
                case didUpdatePassword(password: String)
                case viewDidDisappear
                case statusChangedToConnecting
                case statusChangedToConnected
                case statusChangedToDisconnected
                case updateTimer(timer: String)
                case updateTrafficStats(upload: Int64, download: Int64)
                case showMap(index: Int?)
                case didSelectProtocol(index: Int)
            }
        }
        struct Response {
            enum ResponseType {
                case presentCountries
                case presentCountry(country: Country)
                case presentError(title: String, message: String)
                case presentPasswordAlert
                case presentStatusConnecting
                case presentStatusConnected
                case presentStatusDisconnected
                case presentTimer(timer: String)
                case presentTrafficStats(upload: Int64, download: Int64)
                case presentMap(index: Int?)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayCountries
                case displayCountry(viewModel: CountryCellViewModelType)
                case displayErrorAlert(title: String, message: String)
                case displayPasswordAlert
                case displayTrafficStats(upload: Int64, download: Int64)
                case displayMap(image: UIImage, transform: CGAffineTransform)
                case displayNavigationTitle(title: String)
                case displayStartButton(image: UIImage)
                case displayPulsate(isEnable: Bool)
                case displayTrafficStackView(isEnable: Bool)
                case displayProtocolSegmentedControl(isEnable: Bool)
            }
        }
    }
    
}

enum Country: String, CaseIterable {
    case random = "RANDOM COUNTRY"
    case USA = "USA"
    
    static subscript(_ index: Int) -> Country {
        return self.allCases[index]
    }
}

enum NetworkProtocol: String, CaseIterable {
    case TCP
    case UDP
    
    static subscript(_ index: Int) -> NetworkProtocol {
        return self.allCases[index]
    }
}

