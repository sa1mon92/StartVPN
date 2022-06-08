//
//  CountriesRouter.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol CountriesRoutingLogic {
    func didSelectCountry(_ country: Country)
}

class CountriesRouter: NSObject, CountriesRoutingLogic {
    
    weak var viewController: CountriesViewController?
    
    // MARK: Routing
    
    func didSelectCountry(_ country: Country) {
        guard let nc = viewController?.navigationController else { return }
        if let vc = nc.getPreviousViewController() as? ConnectViewController {
            nc.popViewController(animated: true)
            vc.interactor?.makeRequest(request: .didSelectCountry(country: country))
        }
    }
}
