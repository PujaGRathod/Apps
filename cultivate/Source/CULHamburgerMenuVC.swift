//
//  CULHamburgerMenuVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class CULHamburgerMenuVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(_ menuButton: UIBarButtonItem, view: UIView) {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector(("revealToggle:"))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
