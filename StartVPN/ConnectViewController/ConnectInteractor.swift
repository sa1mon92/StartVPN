//
//  ConnectInteractor.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol ConnectBusinessLogic {
    func makeRequest(request: Connect.Model.Request.RequestType)
}

class ConnectInteractor: ConnectBusinessLogic {
    
    var presenter: ConnectPresentationLogic?
    var service: ConnectService?
    
    func makeRequest(request: Connect.Model.Request.RequestType) {
        if service == nil {
            service = ConnectService()
            service?.interactor = self
        }
        switch request {
        case .countryButtonTouch:
            presenter?.presentData(response: .presentCountries)
        case .didSelectCountry(country: let country):
            presenter?.presentData(response: .presentCountry(country: country))
        case .didChangeConnectingStatus(status: let status):
            presenter?.presentData(response: .presentConnectingStatus(status: status))
        case .startButtonTouch:
            service?.startConnecting()
        case .showError(title: let title, message: let message):
            presenter?.presentData(response: .presentError(title: title, message: message))
        case .showPasswordAlert:
            presenter?.presentData(response: .presentPasswordAlert)
        case .didUpdatePassword:
            service?.startConnecting()
        }
    }
    
}
