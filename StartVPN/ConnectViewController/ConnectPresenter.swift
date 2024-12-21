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
        case .presentError(title: let title, message: let message):
            viewController?.displayData(viewModel: .displayErrorAlert(title: title, message: message))
        case .presentPasswordAlert:
            viewController?.displayData(viewModel: .displayPasswordAlert)
        case .presentStatusConnecting:
            viewController?.displayData(viewModel: .displayNavigationTitle(title: "CONNECTING"))
            viewController?.displayData(viewModel: .displayPulsate(isEnable: true))
            viewController?.displayData(viewModel: .displayProtocolSegmentedControl(isEnable: false))
            if let image = UIImage(named: "Connect.png") {
                viewController?.displayData(viewModel: .displayStartButton(image: image))
            }
        case .presentStatusConnected:
            viewController?.displayData(viewModel: .displayPulsate(isEnable: false))
            viewController?.displayData(viewModel: .displayTrafficStackView(isEnable: true))
            if let image = UIImage(named: "Off.png") {
                viewController?.displayData(viewModel: .displayStartButton(image: image))
            }
        case .presentStatusDisconnected:
            viewController?.displayData(viewModel: .displayNavigationTitle(title: "DISCONNECTED"))
            viewController?.displayData(viewModel: .displayPulsate(isEnable: true))
            viewController?.displayData(viewModel: .displayTrafficStackView(isEnable: false))
            viewController?.displayData(viewModel: .displayProtocolSegmentedControl(isEnable: true))
            if let image = UIImage(named: "On.png") {
                viewController?.displayData(viewModel: .displayStartButton(image: image))
            }
        case .presentTimer(timer: let timer):
            viewController?.displayData(viewModel: .displayNavigationTitle(title: "CONNECTED \(timer)"))
        case .presentTrafficStats(upload: let upload, download: let download):
            viewController?.displayData(viewModel: .displayTrafficStats(upload: upload, download: download))
        case .presentMap(index: let index):
            guard let image = getMapImage(from: index) else { return }
            let transform = getMapTransform(from: index)
            viewController?.displayData(viewModel: .displayMap(image: image, transform: transform))
        }
    }
    
    private func getMapImage(from index: Int?) -> UIImage? {
        if let index = index, index != 0 {
            return UIImage(named: "map_\(index)")
        } else {
            return UIImage(named: "map")
        }
    }
    
    private func getMapTransform(from index: Int?) -> CGAffineTransform {
        
        var scale = CGAffineTransform()
        var translation = CGAffineTransform()
        
        switch index {
        case 1,2:
            scale = CGAffineTransform(scaleX: 2, y: 2)
            translation = CGAffineTransform(translationX: 200, y: 80)
            return scale.concatenating(translation)
        case 3,4,5:
            scale = CGAffineTransform(scaleX: 6, y: 6)
            translation = CGAffineTransform(translationX: 0, y: 150)
            return scale.concatenating(translation)
        default:
            return .identity
        }
    }
}
