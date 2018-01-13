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
import KLCPopup

class DashboardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var contacts: [CULContact] = []
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private var dashboardTableViewAdapter = DashboardTableViewAdapter()
    private var reschedulePopupVC: ReschedulePopupVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController.searchResultsUpdater = self.dashboardTableViewAdapter
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search by name or tag"
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        }
        self.definesPresentationContext = true
        
        self.dashboardTableViewAdapter.setup(for: self.tableView, searchController: self.searchController)
        
        self.dashboardTableViewAdapter.followupButtonTapped = { indexPath, contact in
            // Followup button tapped for a contact from tableView
            print("Followup: \(contact.name), index: \(indexPath.section),\(indexPath.item)")
        }
        self.dashboardTableViewAdapter.rescheduleButtonTapped = { indexPath, contact in
            // Reschedule button tapped for a contact from tableView
            print("Reschedule: \(contact.name), index: \(indexPath.section),\(indexPath.item)")
            self.reschedulePopup(for: contact, tableViewIndexPath: indexPath)
        }
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

    func reschedulePopup(for contact: CULContact, tableViewIndexPath: IndexPath) {
        self.reschedulePopupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReschedulePopupVC") as? ReschedulePopupVC
        if let reschedulePopupVC = self.reschedulePopupVC {
            reschedulePopupVC.followupDateUpdated = {
                self.dashboardTableViewAdapter.reloadData()
            }
            reschedulePopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            reschedulePopupVC.contact = contact
            reschedulePopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(reschedulePopupVC.view)
            let layout = KLCPopupLayout(horizontal: .center, vertical: .center)
            let contentView = reschedulePopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            reschedulePopupVC.popup = popup
            if let popup = popup {
                popup.show(with: layout);
            }
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
