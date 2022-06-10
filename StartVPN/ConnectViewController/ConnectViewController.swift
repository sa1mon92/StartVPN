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
    @IBOutlet weak var trafficStackView: UIStackView!
    @IBOutlet weak var trafficUploadLabel: UILabel!
    @IBOutlet weak var trafficDownloadLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var protocolSegmentedControl: UISegmentedControl!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
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
        navigationItem.title = "DISCONNECTED"
        trafficStackView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupStartButton()
        setupCountryChangeButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        interactor?.makeRequest(request: .viewDidDisappear)
    }
    
    func displayData(viewModel: Connect.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayCountries:
            router?.showCountries()
        case .displayCountry(viewModel: let viewModel):
            countryButton.setTitle(viewModel.countryName, for: .normal)
            countryButton.setImage(viewModel.countryImage, for: .normal)
        case .displayErrorAlert(title: let title, message: let message):
            displayErrorAlert(title: title, message: message)
        case .displayPasswordAlert:
            displayPasswordAlert()
        case .displayTrafficStats(upload: let upload, download: let download):
            trafficUploadLabel.text = Units(bytes: upload).getReadableUnit()
            trafficDownloadLabel.text = Units(bytes: download).getReadableUnit()
        case .displayMap(image: let image, transform: let transform):
            UIView.transition(with: self.mapImage,
                              duration: 2.0,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.mapImage.transform = transform
                                  self.mapImage.image = image
                              },
                              completion: nil)
        case .displayNavigationTitle(title: let title):
            navigationItem.title = title
        case .displayStartButton(image: let image):
            startButton.setImage(image, for: .normal)
        case .displayPulsate(isEnable: let isEnable):
            startButton.pulsate(isEnable)
        case .displayTrafficStackView(isEnable: let isEnable):
            trafficStackView.isHidden = !isEnable
        case .displayProtocolSegmentedControl(isEnable: let isEnable):
            protocolSegmentedControl.isHidden = !isEnable
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
        interactor?.makeRequest(request: .didSelectProtocol(index: protocolSegmentedControl.selectedSegmentIndex))
        interactor?.makeRequest(request: .startButtonTouch)
    }
    
    @IBAction func countryButtonTouch(_ sender: UIButton) {
        interactor?.makeRequest(request: .countryButtonTouch)
    }
}

// Alert actions
extension ConnectViewController {
    
    private func displayErrorAlert(title: String, message: String) {
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
                self.interactor?.makeRequest(request: .didUpdatePassword(password: password))
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}
