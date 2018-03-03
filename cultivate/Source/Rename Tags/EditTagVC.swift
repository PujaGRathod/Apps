//
//  EditTagVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 23/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class EditTagVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var tag: CULTag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        self.addBorderAndBackground(to: self.textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.text = self.tag.name
    }
    
    private func addBorderAndBackground(to view: UIView) {
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        view.layer.borderWidth = 1
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func submitButtonTapped(_ sender: UIBarButtonItem) {
        self.tag.name = self.textField.text
        if let user = CULFirebaseGateway.shared.loggedInUser {
            self.navigationController?.dismiss(animated: true, completion: {
            })
            CULFirebaseGateway.shared.update(tag: self.tag, for: user, completion: { (error) in
            })
            
            let id = "Rename"
            let name = "Tag"
            let contentType = "Submit"
            CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
        }
    }
}
