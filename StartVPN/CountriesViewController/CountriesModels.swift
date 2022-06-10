//
//  CountriesModels.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Countries {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getCountries
                case didSelectRowAt(indexPath: IndexPath)
            }
        }
        struct Response {
            enum ResponseType {
                case presentCountries
                case presentCountry(country: Country)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayCountries(viewModel: CountriesViewModelType)
                case dysplayCountry(country: Country)
            }
        }
    }
    
}

protocol CountriesViewModelType {
    let cells: [CountryCellViewModelType]
    func cellViewModel(forIndexPath: IndexPath) -> CountryCellViewModelType?
}

protocol CountryCellViewModelType {
    let countryName: String
    let countryImage: UIImage?
}

struct CountriesViewModel: CountriesViewModelType {
    
    let cells: [Cell]
    
    struct Cell: CountryCellViewModelType {
        let countryName: String
        let countryImage: UIImage?
        
        init(country: Country) {
            var image: UIImage?
            if let imageIndex = Country.allCases.firstIndex(where: { $0 == country}) {
                image = UIImage(named: "logo_\(String(describing: imageIndex))")
            }
            self.countryName = country.rawValue
            self.countryImage = image
        }
    }
    
    init(countries: [Country]) {
        var cells = [Cell]()
        for country in countries {
            let cell = Cell(country: country)
            cells.append(cell)
        }
        self.cells = cells
    }
    
    func cellViewModel(forIndexPath: IndexPath) -> CountryCellViewModelType? {
        return cells[IndexPath.row]
    }
}
