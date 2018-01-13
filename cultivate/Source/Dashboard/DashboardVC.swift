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
    
    private var contacts: [CULContact] = []
    private var dashboardTableViewAdapter = DashboardTableViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dashboardTableViewAdapter.setup(for: self.tableView, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Generate initial followup dates for all contacts
        self.contacts = FollowupDateGenerator.assignInitialFollowupDates(for: self.contacts)
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: self.contacts, for: user, completion: { (error) in
                print("Contacts saved - DashboardVC")
            })
        }
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
