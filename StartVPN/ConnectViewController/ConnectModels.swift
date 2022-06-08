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
                case didChangeConnectingStatus(status: ConnectingStatus)
                case showError(title: String, message: String)
                case showPasswordAlert
                case didUpdatePassword
            }
        }
        struct Response {
            enum ResponseType {
                case presentCountries
                case presentCountry(country: Country)
                case presentConnectingStatus(status: ConnectingStatus)
                case presentError(title: String, message: String)
                case presentPasswordAlert
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayCountries
                case displayCountry(viewModel: CountriesViewModel.Cell)
                case displayConnectingStatus(status: ConnectingStatus)
                case displayError(title: String, message: String)
                case displayPasswordAlert
            }
        }
    }
    
}

enum Country: String, CaseIterable {
    case random = "RANDOM COUNTRY"
    case USA = "USA"
    case Canada = "CANADA"
    case Germany = "GERMANY"
    case France = "FRANCE"
    case Poland = "POLAND"
    
    static subscript(_ index: Int) -> Country {
        return self.allCases[index]
    }
}

enum ConnectingStatus: String {
    case invalid
    case disconnected
    case connecting
    case connected
    case reasserting
    case disconnecting
}
