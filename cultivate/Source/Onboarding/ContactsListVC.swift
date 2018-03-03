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
        
        if let mode = self.mode {
            ContactSelectionProcessDataStore.shared.mode = mode
        } else {
            self.mode = ContactSelectionProcessDataStore.shared.mode
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
        
        if let sortOrder = CULContact.SortOrder(rawValue: UserDefaults.standard.integer(forKey: "KEY_CONTACT_SORT_ORDER")) {
            self.selectedSortOrder = sortOrder
        }
    }
    
    func setTableViewAdapterWithSelectedContacts() {
        DispatchQueue.main.async {
            self.contactsListTableViewAdapter.delegate = self
            self.contactsListTableViewAdapter.set(tableView: self.tblContactsList, with: self.selectedContacts)
            
            DispatchQueue.main.async {
                self.showHUD()
            }
            self.contactsListTableViewAdapter.loadContactsFromAddressbook(with: self.selectedSortOrder, {
                self.hideHUD()
            })
            
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
            self.getDeselectedContacts(from: self.selectedContacts, { (contactsToDelete) in
                ContactSelectionProcessDataStore.shared.setNewContacts(from: self.selectedContacts)
                if let user = CULFirebaseGateway.shared.loggedInUser {
                    CULFirebaseGateway.shared.delete(contacts: contactsToDelete, for: user, { (error) in
                        print("Error while deleting: \(error?.localizedDescription ?? "N.A")")
                        proceed()
                    })
                }
                func proceed() {
                    if ContactSelectionProcessDataStore.shared.getNewContacts().count > 0 {
                        self.performSegue(withIdentifier: "segueSelectFrequency", sender: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            })
        }
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
            self.showHUD()
            self.contactsListTableViewAdapter.loadContactsFromAddressbook(with: self.selectedSortOrder, {
                self.hideHUD()
            })
        })
        actionSheet.addAction(action1)

        let action2 = UIAlertAction(title: actionTitle2, style: UIAlertActionStyle.default, handler: { (action) in
            self.selectedSortOrder = CULContact.SortOrder.lastName
            self.showHUD()
            self.contactsListTableViewAdapter.loadContactsFromAddressbook(with: self.selectedSortOrder, {
                self.hideHUD()
            })
        })
        actionSheet.addAction(action2)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        actionSheet.view.tintColor = self.navigationController?.navigationBar.tintColor
        
        self.present(actionSheet, animated: true) {
        }
    }
    
    /*
     If the contact from cultivate contact list is NOT available in the selectedContacts list. then it should be removed from cultivate contacts.
     */
    private func getDeselectedContacts(from selectedContacts: [CULContact], _ completion: @escaping (([CULContact])->Void)) {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                var cultivateContactsToDelete = [CULContact]()
                let currentCultivateContacts = contacts
                for cultivateContact in currentCultivateContacts {
                    if selectedContacts.filter({ $0.identifier == cultivateContact.identifier }).first == nil {
                        cultivateContactsToDelete.append(cultivateContact)
                    }
                }
                completion(cultivateContactsToDelete)
            })
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
