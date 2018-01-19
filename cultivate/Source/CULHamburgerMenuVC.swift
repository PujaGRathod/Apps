//
//  CULHamburgerMenuVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.item == 3 {
            // Logout
            self.logoutTapped()
        }
    }
    
    private func logoutTapped() {
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        self.performSegue(withIdentifier: "segueAuthentication", sender: nil)
    }
}
