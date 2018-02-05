//
//  DashboardVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 03/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup
import Instructions
import StoreKit

class DashboardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var logFollowupButton: UIBarButtonItem!
    @IBOutlet weak var firstCoachMarkView: UIView!
    
    private var coachMarksController = CoachMarksController()
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
        
        self.dashboardTableViewAdapter.contactsLoaded = {
            self.updateContacts()
            self.showHelpPopovers()
            self.hideHUD()
        }
        
        self.dashboardTableViewAdapter.setup(for: self.tableView, searchController: self.searchController)
        
        self.dashboardTableViewAdapter.followupButtonTapped = { indexPath, contact in
            // Followup button tapped for a contact from tableView
            print("Followup: \(contact.name), index: \(indexPath.section),\(indexPath.item)")
            self.logFollowupPopup(for: contact, tableViewIndexPath: indexPath)
            
            let id = CULFirebaseAnalyticsManager.Keys.Identifiers.followup.rawValue
            let name = "CONTACT"
            let contentType = CULFirebaseAnalyticsManager.Keys.ContentTypes.followup.rawValue
            CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
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
        self.showHUD(with: "Refreshing contacts")
        self.dashboardTableViewAdapter.getContacts()
        self.updateContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.askForReview()
        self.showHelpPopovers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContactDetails" {
            if let vc = segue.destination as? ContactDetailsVC {
                vc.contact = sender as! CULContact
            }
        }
    }

    func updateContacts() {
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
            reschedulePopupVC.followupDateUpdated = { updatedContact in
                self.dashboardTableViewAdapter.update(contact: updatedContact)
                
                let id = "FOLLOWUP"
                let name = "CONTACT_DASHBOARD"
                let contentType = "DEFER_DATE"
                CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
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
            logFollowupPopupVC.contact = contact
            logFollowupPopupVC.presentingVC = self
            
            // Ugly hack to force system to load the UIView
            logFollowupPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            print(logFollowupPopupVC.view)
            let verticalLayout = KLCPopupVerticalLayout.aboveCenter
            let layout = KLCPopupLayout(horizontal: .center, vertical: verticalLayout)
            
            let contentView = logFollowupPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            logFollowupPopupVC.popup = popup
            if let popup = popup {
                logFollowupPopupVC.loadContactDetails()
                popup.didFinishShowingCompletion = {
                    logFollowupPopupVC.showHelpPopovers()
                }
                popup.show(with: layout)
            }
        }
    }
    
    @IBAction func logFollowupButtonTapped(_ sender: UIBarButtonItem) {
        self.logFollowupPopup(for: nil, tableViewIndexPath: nil)
        
        let id = CULFirebaseAnalyticsManager.Keys.Identifiers.followup.rawValue
        let name = "STAND-ALONE"
        let contentType = CULFirebaseAnalyticsManager.Keys.ContentTypes.followup.rawValue
        CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
    }
}

extension DashboardVC: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    func showHelpPopovers() {
        if self.shouldShowHelp() {
            self.didShowHelp()
            self.coachMarksController.dataSource = self
            self.coachMarksController.start(on: self)
        }
    }
    
    private func shouldShowHelp() -> Bool {
        let defaults = UserDefaults.standard
        return !(defaults.bool(forKey: "DASHBOARD_HELP_SHOWN"))
    }
    
    private func didShowHelp() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "DASHBOARD_HELP_SHOWN")
        defaults.synchronize()
    }

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        if index == 0 {
            return coachMarksController.helper.makeCoachMark(for: self.firstCoachMarkView, pointOfInterest: nil, cutoutPathMaker: { (rect) -> UIBezierPath in
                return UIBezierPath(rect: rect)
            })
        } else if index == 1 {
            if let button = self.dashboardTableViewAdapter.getFirstLogFollowupButton() {
                return coachMarksController.helper.makeCoachMark(for: button)
            } else {
                return coachMarksController.helper.makeCoachMark(for: self.tableView)
            }
        } else {
            if let view = self.logFollowupButton.view {
                return coachMarksController.helper.makeCoachMark(for: view)
            } else {
                return coachMarksController.helper.makeCoachMark(for: self.view)
            }
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let shouldShowArrow = (index == 0) ? false : true
        let arrowOrientation: CoachMarkArrowOrientation? = (index == 0) ? nil : coachMark.arrowOrientation
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: shouldShowArrow, withNextText: false, arrowOrientation: arrowOrientation)
        
        var hintText = ""
        if index == 0 {
            hintText = "Welcome to the Dashboard! This is where you will find your next suggested follow-up dates for each of your Cultivate Contacts\n\nCultivate automatically suggests follow-ups based on 1) the last date you reached out to that contact and  2) your selected follow-up frequency for that contact.\n\nTap to continue"
        } else if index == 1 {
            hintText = "Select the “log follow-up” icon after you complete a follow-up with a contact.\n\nYou can also swipe left on a contact to reschedule the follow-up"
        } else if index == 2 {
            hintText = "You can also log a follow-up with any Cultivate contact, even if they’re aren’t listed below\n\nThis may be useful if you have an unexpected run-in with one of your Cultivate contacts"
        }
        coachViews.bodyView.hintLabel.text = hintText
        
//        coachViews.bodyView.layer.borderWidth = 3
//        coachViews.bodyView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
//        coachViews.bodyView.layer.cornerRadius = 8
        
//        coachViews.arrowView?.layer.borderWidth = 3
//        coachViews.arrowView?.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
//        coachViews.bodyView.layer.cornerRadius = 8
        
//        coachViews.arrowView?.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
//        coachViews.arrowView?.isHighlighted = true
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension DashboardVC {
    
    func askForReview() {
        let reviewManager = RequestReviewManager()
        reviewManager.askForReview()
    }
}
