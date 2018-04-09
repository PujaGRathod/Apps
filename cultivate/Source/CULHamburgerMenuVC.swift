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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let gesture = self.revealViewController().panGestureRecognizer(),
            let frontVC = self.revealViewController().frontViewController {
            self.revealViewController().view.addGestureRecognizer(gesture)
            frontVC.revealViewController().tapGestureRecognizer()
            frontVC.view.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let gesture = self.revealViewController().panGestureRecognizer(),
            let view = self.revealViewController().frontViewController.view {
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = true
        }
    }
    
    func configure(_ menuButton: UIBarButtonItem, view: UIView) {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector(("revealToggle:"))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.item == 4 {
            // Logout
            self.logoutTapped()
        }
    }
    
    private func logoutTapped() {
        let alert = UIAlertController(title: "Sure?", message: "Do you really want to Logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive, handler: { (action) in
//            CULFirebaseGateway.shared.localPersistence(false)
            GIDSignIn.sharedInstance().signOut()
            FBSDKLoginManager().logOut()
            do {
                try Auth.auth().signOut()
            } catch {
                print(error.localizedDescription)
            }
            self.performSegue(withIdentifier: "segueAuthentication", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAddMissingTags" {
            ContactSelectionProcessDataStore.shared.mode = .addMissingTags
        }
    }
}
