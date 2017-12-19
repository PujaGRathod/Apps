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
    @IBOutlet weak var searchBar: UISearchBar!
    
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    lazy var filteredContacts: [CULContact] = []
    lazy var allContacts: [CULContact] = []
    lazy var selectedContacts: [CULContact] = []
    private var contactsListTableViewAdapter: ContactListTableViewAdapter = ContactListTableViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adjustContinueButtonVisibility()
        self.contactsListTableViewAdapter.delegate = self
        self.contactsListTableViewAdapter.set(tableView: self.tblContactsList)
        
        self.searchController.searchResultsUpdater = self.contactsListTableViewAdapter
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search contacts"
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        }
        self.definesPresentationContext = true
        
        self.contactsListTableViewAdapter.set(searchController: self.searchController)
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
        self.bottomMarginConstraintForContinueButton.constant = (selectedContacts.count > 0) ? 12 : -64
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowFollowupFrequenciesInformationVC",
            let viewcontroller: SetFollowupFrequenciesInformationVC = segue.destination as! SetFollowupFrequenciesInformationVC {
            viewcontroller.selectedContacts = self.selectedContacts
        }
    }
}

extension ContactsListVC: ContactListTableViewAdapterDelegate {
    func selectionChanged(selectedContacts: [CULContact]) {
        self.selectedContacts = selectedContacts
        self.lblSelectedContactsCount.text = "\(selectedContacts.count)"
        
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
