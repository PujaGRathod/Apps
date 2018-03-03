//
//  ViewContactsListVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup

class ViewContactsListVC: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tblContactsList: UITableView!
    @IBOutlet weak var tagFilterView: UIView!
    @IBOutlet weak var tagValueButton: UIButton!
    
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private var contactsListTableViewAdapter: ContactListTableViewAdapter = ContactListTableViewAdapter()
    private var tags = [CULTag]()
    private var selectedTag: CULTag?
    private var allContacts = [CULContact]()
    private var tagPickerPopupVC: TagPickerPopupVC?
    private var selectedSortOrder = CULContact.SortOrder.firstName {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(self.selectedSortOrder.rawValue, forKey: "KEY_CONTACT_SORT_ORDER")
            defaults.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
        
        self.addBorderAndBackground(to: self.tagFilterView)
        self.tagValueButton.setTitle(self.selectedTag?.name ?? "No filter", for: .normal)
        
        if let sortOrder = CULContact.SortOrder(rawValue: UserDefaults.standard.integer(forKey: "KEY_CONTACT_SORT_ORDER")) {
            self.selectedSortOrder = sortOrder
        }
        
        let id = "FOLLOWUP"
        let name = "CONTACT_DASHBOARD"
        let contentType = "DEFER_DATE"
        CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
    }
    
    private func addBorderAndBackground(to view: UIView) {
        view.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = #colorLiteral(red: 0.3803921569, green: 0.368627451, blue: 0.3843137255, alpha: 1)
        view.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = CULFirebaseGateway.shared.loggedInUser {
            self.showHUD(with: "Loading contacts")
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                self.hideHUD()
                DispatchQueue.main.async {
                    self.show(contacts: contacts)
                    self.tags = self.getTags(from: contacts)
                }
            })
        }
        if let selectedRowIndexPath = self.tblContactsList.indexPathForSelectedRow {
            self.tblContactsList.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
    private func show(contacts: [CULContact]) {
        self.allContacts = contacts
        
        self.contactsListTableViewAdapter.set(tableView: self.tblContactsList, with: [])
        self.contactsListTableViewAdapter.allowMultipleSelection = false
        self.contactsListTableViewAdapter.delegate = self
        
        self.searchController.searchResultsUpdater = self.contactsListTableViewAdapter
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search contacts"
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        }
        self.definesPresentationContext = true
        
        self.contactsListTableViewAdapter.set(searchController: self.searchController)
        self.contactsListTableViewAdapter.load(contacts: contacts, with: self.selectedSortOrder)
    }
    
    private func filterContacts(for tag: CULTag?) {
        if let tag = tag {
            let filteredContacts = self.allContacts.filter({ (contact) -> Bool in
                return contact.tag?.identifier == tag.identifier
            })
            self.contactsListTableViewAdapter.load(contacts: filteredContacts, with: self.selectedSortOrder)
        } else {
            self.contactsListTableViewAdapter.load(contacts: self.allContacts, with: self.selectedSortOrder)
        }
    }
    
    func showTagPicker() {
        self.tagPickerPopupVC = self.storyboard?.instantiateViewController(withIdentifier: "TagPickerPopupVC") as? TagPickerPopupVC
        if let tagPickerPopupVC = self.tagPickerPopupVC {
            tagPickerPopupVC.tagUpdated = { updatedTag in
                self.selectedTag = updatedTag
                var tagName = "No filter"
                if let tag = updatedTag {
                    tagName = tag.name
                }
                self.tagValueButton.setTitle(tagName, for: .normal)
                self.filterContacts(for: updatedTag)
                
                let id = "APPLY"
                let name = "CULTIVATE_CONTACTS"
                let contentType = "FILTER"
                CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
            }
            tagPickerPopupVC.shouldShowAddNewTagTextField = false
            tagPickerPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            tagPickerPopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(tagPickerPopupVC.view)
            
            let contentView = tagPickerPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            tagPickerPopupVC.popup = popup
            tagPickerPopupVC.set(tag: self.selectedTag, allTags: self.tags)
        }
    }
    
    // List of tags which have at least 1 contact attached to it
    private func getTags(from contacts: [CULContact]) -> [CULTag] {
        var tags = [CULTag]()
        for contact in contacts {
            if tags.contains(where: { $0.identifier == contact.tag?.identifier }) == false {
                if let tag = contact.tag {
                    tags.append(tag)
                }
            }
        }
        return tags
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContactDetails",
            let vc = segue.destination as? ContactDetailsVC {
            
            vc.contact = sender as! CULContact
        } else if segue.identifier == "segueEditContacts",
            let vc = segue.destination as? ContactsListVC {
            vc.mode = ContactSelectionProcessDataStore.Mode.updatingContacts
        }
    }
    
    @IBAction func changeTagTapped(_ sender: UIButton) {
        self.showTagPicker()
    }

    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Sort order", message: "Please select sort order", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        var actionTitle1 = "First, Last"
        var actionTitle2 = "Last, First"
        let checkmark = " \u{2713}"
        if self.selectedSortOrder == .firstName {
            actionTitle1 += checkmark
            actionTitle2 += "   "
        } else {
            actionTitle1 += "   "
            actionTitle2 += checkmark
        }
        
        let action1 = UIAlertAction(title: actionTitle1, style: UIAlertActionStyle.default, handler: { (action) in
            self.selectedSortOrder = CULContact.SortOrder.firstName
            self.contactsListTableViewAdapter.load(contacts: self.allContacts, with: self.selectedSortOrder)
        })
        actionSheet.addAction(action1)
        
        let action2 = UIAlertAction(title: actionTitle2, style: UIAlertActionStyle.default, handler: { (action) in
            self.selectedSortOrder = CULContact.SortOrder.lastName
            self.contactsListTableViewAdapter.load(contacts: self.allContacts, with: self.selectedSortOrder)
        })
        actionSheet.addAction(action2)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        actionSheet.view.tintColor = self.navigationController?.navigationBar.tintColor
        
        self.present(actionSheet, animated: true) {
        }
    }

}

extension ViewContactsListVC: ContactListTableViewAdapterDelegate {
    
    func contactsLoaded(_ contacts: [CULContact]) {
        
    }
    
    func selectionChanged(selectedContacts: [CULContact]) {
        if let contact = selectedContacts.first {
            self.performSegue(withIdentifier: "segueContactDetails", sender: contact)
        }
    }
    
    func searchControllerSetupCompleted(_ searchController: UISearchController) {
        
    }
}
