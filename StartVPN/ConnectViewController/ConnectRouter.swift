//
//  ConnectRouter.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol ConnectRoutingLogic {
    func showCountries()
}

class ConnectRouter: NSObject, ConnectRoutingLogic {
    
    weak var viewController: ConnectViewController?
    
    // MARK: Routing
    func showCountries() {
        guard let nc = viewController?.navigationController else { return }
        let countriesViewController = CountriesViewController(nibName: "CountriesViewController", bundle: nil)
        nc.pushViewController(countriesViewController, animated: true)
    }
}
