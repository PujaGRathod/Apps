//
//  ContactsListVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class ContactsListVC: UIViewController {
    
    @IBOutlet weak var tblContactsList: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewSelectedContactsCount: UIView!
    @IBOutlet weak var lblSelectedContactsCount: UILabel!
    @IBOutlet weak var bottomMarginConstraintForContinueButton: NSLayoutConstraint!
    
    var mode: ContactSelectionProcessDataStore.Mode?
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    lazy var filteredContacts: [CULContact] = []
    lazy var allContacts: [CULContact] = []
    lazy var selectedContacts: [CULContact] = []
    private var contactsListTableViewAdapter: ContactListTableViewAdapter = ContactListTableViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mode = self.mode {
            ContactSelectionProcessDataStore.shared.mode = mode
        }
        if self.mode == .onboarding {
            self.selectedContacts = ContactSelectionProcessDataStore.shared.getContacts()
            self.setTableViewAdapterWithSelectedContacts()
        } else if self.mode == .updatingContacts {
            self.title = "Edit Contacts"
            if let user = CULFirebaseGateway.shared.loggedInUser {
                CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                    self.selectedContacts = contacts
                    self.setTableViewAdapterWithSelectedContacts()
                })
            }
        }
        
        self.adjustContinueButtonVisibility()
        
    }
    
    func setTableViewAdapterWithSelectedContacts() {
        DispatchQueue.main.async {
            self.contactsListTableViewAdapter.delegate = self
            self.contactsListTableViewAdapter.set(tableView: self.tblContactsList, with: self.selectedContacts)
            self.contactsListTableViewAdapter.loadContactsFromAddressbook()
            self.searchController.searchResultsUpdater = self.contactsListTableViewAdapter
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.placeholder = "Search contacts"
            if #available(iOS 11.0, *) {
                self.navigationItem.searchController = self.searchController
            }
            self.definesPresentationContext = true
            
            self.contactsListTableViewAdapter.allowMultipleSelection = true
            self.contactsListTableViewAdapter.set(searchController: self.searchController)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewSelectedContactsCount.layer.cornerRadius = 36/2
        self.lblSelectedContactsCount.layer.cornerRadius = 28/2
    }
    
    func adjustContinueButtonVisibility() {
        self.bottomMarginConstraintForContinueButton.constant = (self.selectedContacts.count > 0) ? 12 : -64
        self.view.layoutIfNeeded()
    }
    
    @IBAction func continueButtonTapped(_ sender: CULButton) {
        if self.selectedContacts.count == 0 {
            self.showErrorMessageForContactSelection()
            return
        }
        if self.mode == .onboarding  {
             self.performSegue(withIdentifier: "segueShowFollowupFrequenciesInformationVC", sender: nil)
        } else if self.mode == .updatingContacts {
            ContactSelectionProcessDataStore.shared.setNewContacts(from: self.selectedContacts)
            self.performSegue(withIdentifier: "segueSelectFrequency", sender: nil)
        }
    }
    
    private func showErrorMessageForContactSelection() {
        let alert: UIAlertController = UIAlertController(title: "Error", message: "Please select atleast one contact.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ContactsListVC: ContactListTableViewAdapterDelegate {
    func selectionChanged(selectedContacts: [CULContact]) {
        self.selectedContacts = ContactSelectionProcessDataStore.shared.update(contacts: selectedContacts)
        self.lblSelectedContactsCount.text = "\(self.selectedContacts.count)"
        
        UIView.animate(withDuration: 0.27) {
            self.adjustContinueButtonVisibility()
        }
    }
    
    func contactsLoaded(_ contacts: [CULContact]) {
        self.allContacts = contacts
    }
    
    func searchControllerSetupCompleted(_ searchController: UISearchController) {
        
    }
}
