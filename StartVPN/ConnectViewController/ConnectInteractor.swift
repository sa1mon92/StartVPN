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
            service?.selectedCountry = country
            presenter?.presentData(response: .presentCountry(country: country))
        case .startButtonTouch:
            service?.startConnecting()
        case .showError(title: let title, message: let message):
            presenter?.presentData(response: .presentError(title: title, message: message))
        case .showPasswordAlert:
            presenter?.presentData(response: .presentPasswordAlert)
        case .viewDidDisappear:
            service?.stopConnecting()
        case .statusChangedToConnecting:
            presenter?.presentData(response: .presentStatusConnecting)
        case .statusChangedToConnected:
            presenter?.presentData(response: .presentStatusConnected)
        case .statusChangedToDisconnected:
            presenter?.presentData(response: .presentStatusDisconnected)
        case .updateTimer(timer: let timer):
            presenter?.presentData(response: .presentTimer(timer: timer))
        case .updateTrafficStats(upload: let upload, download: let download):
            presenter?.presentData(response: .presentTrafficStats(upload: upload, download: download))
        case .showMap(index: let index):
            presenter?.presentData(response: .presentMap(index: index))
        case .didUpdatePassword(password: let password):
            UserDefaults.standard.set(password, forKey: "password")
            service?.startConnecting()
        case .didSelectProtocol(index: let index):
            service?.networkProtocol = NetworkProtocol[index]
        }
    }
    
}
