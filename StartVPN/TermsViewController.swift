//
//  TermsViewController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 14.04.2021.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.backgroundColor = .white
        textView.isEditable = false
    }
    @IBAction func buttonExit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
