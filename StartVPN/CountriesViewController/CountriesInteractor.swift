//
//  CountriesInteractor.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol CountriesBusinessLogic {
    func makeRequest(request: Countries.Model.Request.RequestType)
}

class CountriesInteractor: CountriesBusinessLogic {
    
    var presenter: CountriesPresentationLogic?
    var service: CountriesService?
    
    func makeRequest(request: Countries.Model.Request.RequestType) {
        if service == nil {
            service = CountriesService()
        }
        switch request {
        case .getCountries:
            presenter?.presentData(response: Countries.Model.Response.ResponseType.presentCountries)
        case .didSelectRowAt(indexPath: let indexPath):
            presenter?.presentData(response: .presentCountry(country: Country[indexPath.row]))
        }
    }
}
