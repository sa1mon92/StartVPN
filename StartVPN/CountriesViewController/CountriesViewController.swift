//
//  CountriesViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol CountriesDisplayLogic: AnyObject {
    func displayData(viewModel: Countries.Model.ViewModel.ViewModelData)
}

class CountriesViewController: UIViewController, CountriesDisplayLogic {
    
    @IBOutlet weak var countriesTableView: UITableView!
    
    var viewModel: CountriesViewModel?
    
    var interactor: CountriesBusinessLogic?
    var router: (NSObjectProtocol & CountriesRoutingLogic)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = CountriesInteractor()
        let presenter             = CountriesPresenter()
        let router                = CountriesRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: Routing
    
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        interactor?.makeRequest(request: Countries.Model.Request.RequestType.getCountries)
    }
    
    func displayData(viewModel: Countries.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayCountries(viewModel: let viewModel):
            self.viewModel = viewModel
            countriesTableView.reloadData()
        case .dysplayCountry(country: let country):
            router?.didSelectCountry(country)
        }
    }
    
    private func setupTableView() {
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        let cellNib = UINib(nibName: "CountriesTableViewCell", bundle: nil)
        countriesTableView.register(cellNib, forCellReuseIdentifier: "Cell")
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "COUNTRIES"
        navigationController?.navigationBar.tintColor = .black
    }
}

extension CountriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cells.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountriesTableViewCell
        
        guard let cellViewModel = viewModel?.cells[indexPath.row] else { return cell }
        cell.countryLabel.text = cellViewModel.countryName
        cell.countryImage.image = cellViewModel.countryImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.makeRequest(request: Countries.Model.Request.RequestType.didSelectRowAt(indexPath: indexPath))
    }
}
