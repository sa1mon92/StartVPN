//
//  ConnectPresenter.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol ConnectPresentationLogic {
    func presentData(response: Connect.Model.Response.ResponseType)
}

class ConnectPresenter: ConnectPresentationLogic {
    weak var viewController: ConnectDisplayLogic?
    
    func presentData(response: Connect.Model.Response.ResponseType) {
        switch response {
        case .presentCountries:
            viewController?.displayData(viewModel: .displayCountries)
        case .presentCountry(country: let country):
            let viewModel = CountriesViewModel.Cell(country: country)
            viewController?.displayData(viewModel: .displayCountry(viewModel: viewModel))
        case .presentConnectingStatus(status: let status):
            viewController?.displayData(viewModel: .displayConnectingStatus(status: status))
        case .presentError(title: let title, message: let message):
            viewController?.displayData(viewModel: .displayError(title: title, message: message))
        case .presentPasswordAlert:
            viewController?.displayData(viewModel: .displayPasswordAlert)
        }
    }
    
}
