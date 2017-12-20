//
//  UIViewControllerExtension.swift
//  cultivate
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in

            }))
            self.present(alertController, animated: true) {

            }
        }
    }

    func showAlert(_ title: String?, message: String?, actionTitle: String, actionStyle: UIAlertActionStyle, actionhandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: actionTitle, style: actionStyle, handler: actionhandler))
            self.present(alertController, animated: true) {

            }
        }
    }

    func showAlert(_ title: String?, message: String?, actionTitles: [String], cancelTitle: String, actionhandler: ((UIAlertAction, Int) -> Swift.Void)? = nil, cancelActionHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            for (index, actionTitle) in actionTitles.enumerated() {
                alertController.addAction(UIAlertAction.init(title: actionTitle, style: .default, handler: { (action) in
                    actionhandler?(action, index)
                }))
            }

            alertController.addAction(UIAlertAction.init(title: cancelTitle, style: .destructive, handler: cancelActionHandler))

            self.present(alertController, animated: true) {

            }
        }
    }

}
