//
//  DashboardVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 03/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit

class DashboardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var dashboardTableViewAdapter = DashboardTableViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dashboardTableViewAdapter.setup(for: self.tableView, delegate: self)
    }
    

    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
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

extension DashboardVC: DashboardTableViewAdapterDelegate {
    
}
