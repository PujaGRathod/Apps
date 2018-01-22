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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
        
        self.addBorderAndBackground(to: self.tagFilterView)
        self.tagValueButton.setTitle(self.selectedTag?.name ?? "No filter", for: .normal)
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
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
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
        self.contactsListTableViewAdapter.load(contacts: contacts)
    }
    
    private func filterContacts(for tag: CULTag?) {
        if let tag = tag {
            let filteredContacts = self.allContacts.filter({ (contact) -> Bool in
                return contact.tag?.identifier == tag.identifier
            })
            self.contactsListTableViewAdapter.load(contacts: filteredContacts)
        } else {
            self.contactsListTableViewAdapter.load(contacts: self.allContacts)
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
            }
            tagPickerPopupVC.shouldShowAddNewTagTextField = false
            tagPickerPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            tagPickerPopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(tagPickerPopupVC.view)
            
            let layout = KLCPopupLayout(horizontal: .center, vertical: .center)
            
            let contentView = tagPickerPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            tagPickerPopupVC.popup = popup
            if let popup = popup {
                popup.show(with: layout)
            }
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
