//
//  CountriesPresenter.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol CountriesPresentationLogic {
    func presentData(response: Countries.Model.Response.ResponseType)
}

class CountriesPresenter: CountriesPresentationLogic {
    weak var viewController: CountriesDisplayLogic?
    
    func presentData(response: Countries.Model.Response.ResponseType) {
        switch response {
        case .presentCountries:
            let viewModel = CountriesViewModel(countries: Country.allCases)
            viewController?.displayData(viewModel: .displayCountries(viewModel: viewModel))
        case .presentCountry(country: let country):
            viewController?.displayData(viewModel: .dysplayCountry(country: country))
        }
    }
}
