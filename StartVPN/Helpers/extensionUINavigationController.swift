//
//  extensionUINavigationController.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//

import UIKit

extension UINavigationController {
    func getPreviousViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 1 else { return nil }
        return viewControllers[count - 2]
    }
}
