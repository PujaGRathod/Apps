//
//  DashboardVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 03/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup

class DashboardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var contacts: [CULContact] = []
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private var dashboardTableViewAdapter = DashboardTableViewAdapter()
    private var reschedulePopupVC: ReschedulePopupVC?
    private var logFollowupPopupVC: LogFollowupPopupVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Find a better place for this single line
        hamburgerMenuVC = self.revealViewController().rearViewController as! CULHamburgerMenuVC
        if ContactSelectionProcessDataStore.shared.getContacts().count > 0 {
            ContactSelectionProcessDataStore.shared.empty()
        }
        
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
        
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
            self.logFollowupPopup(for: contact, tableViewIndexPath: indexPath)
        }
        self.dashboardTableViewAdapter.rescheduleButtonTapped = { indexPath, contact in
            // Reschedule button tapped for a contact from tableView
            print("Reschedule: \(contact.name), index: \(indexPath.section),\(indexPath.item)")
            self.reschedulePopup(for: contact, tableViewIndexPath: indexPath)
        }
        self.dashboardTableViewAdapter.contactSelected = { contact in
            self.performSegue(withIdentifier: "segueContactDetails", sender: contact)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContactDetails" {
            if let vc = segue.destination as? ContactDetailsVC {
                vc.contact = sender as! CULContact
            }
        }
    }

    func reschedulePopup(for contact: CULContact, tableViewIndexPath: IndexPath) {
        self.reschedulePopupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReschedulePopupVC") as? ReschedulePopupVC
        if let reschedulePopupVC = self.reschedulePopupVC {
            reschedulePopupVC.followupDateUpdated = { updatedContact in
                self.dashboardTableViewAdapter.update(contact: updatedContact)
            }
            reschedulePopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            reschedulePopupVC.contact = contact
            reschedulePopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(reschedulePopupVC.view)
            
            let verticalLayout = KLCPopupVerticalLayout.aboveCenter
            let layout = KLCPopupLayout(horizontal: .center, vertical: verticalLayout)
            
            let contentView = reschedulePopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            reschedulePopupVC.popup = popup
            if let popup = popup {
                popup.show(with: layout);
            }
        }
    }
    
    func logFollowupPopup(for contact: CULContact?, tableViewIndexPath: IndexPath?) {
        self.logFollowupPopupVC = self.storyboard?.instantiateViewController(withIdentifier: "LogFollowupPopupVC") as? LogFollowupPopupVC
        if let logFollowupPopupVC = self.logFollowupPopupVC {
            logFollowupPopupVC.followupLogged = { updatedContact in
                self.dashboardTableViewAdapter.update(contact: updatedContact)
            }
            logFollowupPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            logFollowupPopupVC.contact = contact
            logFollowupPopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(logFollowupPopupVC.view)
            let verticalLayout = KLCPopupVerticalLayout.aboveCenter
            let layout = KLCPopupLayout(horizontal: .center, vertical: verticalLayout)
            
            let contentView = logFollowupPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            logFollowupPopupVC.popup = popup
            if let popup = popup {
                popup.show(with: layout)
            }
            logFollowupPopupVC.loadContactDetails()
        }
    }
    
    @IBAction func logFollowupButtonTapped(_ sender: UIBarButtonItem) {
        self.logFollowupPopup(for: nil, tableViewIndexPath: nil)
    }
}
