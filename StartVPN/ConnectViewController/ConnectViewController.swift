//
//  ConnectViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 06.06.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol ConnectDisplayLogic: AnyObject {
    func displayData(viewModel: Connect.Model.ViewModel.ViewModelData)
}

class ConnectViewController: UIViewController, ConnectDisplayLogic {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    
    var interactor: ConnectBusinessLogic?
    var router: (NSObjectProtocol & ConnectRoutingLogic)?
    
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
        let interactor            = ConnectInteractor()
        let presenter             = ConnectPresenter()
        let router                = ConnectRouter()
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
        self.navigationItem.title = "DISCONNECTED"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupStartButton()
        setupCountryChangeButton()
    }
    
    func displayData(viewModel: Connect.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayCountries:
            router?.showCountries()
        case .displayCountry(viewModel: let viewModel):
            countryButton.setTitle(viewModel.countryName, for: .normal)
            countryButton.setImage(viewModel.countryImage, for: .normal)
        case .displayConnectingStatus(status: let status):
            displayConnectingStatus(status: status)
        case .displayError(title: let title, message: let message):
            displayError(title: title, message: message)
        case .displayPasswordAlert:
            displayPasswordAlert()
        }
    }
    
    private func displayError(title: String, message: String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction (title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func displayPasswordAlert() {
        let alert = UIAlertController (title: "Please enter new password", message: "Failed to establish a connection. Your password may be missing or outdated", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter new password"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            let tf = alert.textFields![0] as UITextField
            if let password = tf.text, password != "" {
                UserDefaults.standard.set(password, forKey: "password")
                self.interactor?.makeRequest(request: .didUpdatePassword)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func displayConnectingStatus(status: ConnectingStatus) {
        
        self.navigationItem.title = status.rawValue.uppercased()
        
        var imageName = ""
        switch status {
        case .invalid:
            startButton.pulsate(false)
            imageName = "On.png"
        case .disconnected:
            startButton.pulsate(false)
            imageName = "On.png"
        case .connecting:
            startButton.pulsate(true)
            imageName = "Connect.png"
        case .connected:
            startButton.pulsate(false)
            imageName = "Off.png"
        case .reasserting:
            startButton.pulsate(false)
            imageName = "On.png"
        case .disconnecting:
            startButton.pulsate(false)
            imageName = "On.png"
        }
        
        if let image = UIImage(named: imageName) {
            startButton.setImage(image, for: .normal)
        }
    }
    
    private func setupStartButton() {
        
        // add shadow
        startButton.layer.shadowColor = UIColor(white: 0.6, alpha: 1).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        startButton.layer.shadowOpacity = 0.9
        startButton.layer.shadowRadius = 10.0
        startButton.layer.masksToBounds = false
        
        //setup size
        for constraint in startButton.constraints {
            if constraint.identifier == "startButtonWidth" {
                constraint.constant = self.view.frame.width / 3
            }
        }
        view.layoutIfNeeded()
    }
    
    private func setupCountryChangeButton() {
        
        for constraint in countryButton.constraints {
            if constraint.identifier == "countryButtonWidth" {
                constraint.constant = self.view.frame.width * 0.7
            }
        }
        view.layoutIfNeeded()
    }
    
    @IBAction func startButtonTouch(_ sender: UIButton) {
        interactor?.makeRequest(request: Connect.Model.Request.RequestType.startButtonTouch)
    }
    
    @IBAction func countryButtonTouch(_ sender: UIButton) {
        interactor?.makeRequest(request: Connect.Model.Request.RequestType.countryButtonTouch)
    }
    
}
