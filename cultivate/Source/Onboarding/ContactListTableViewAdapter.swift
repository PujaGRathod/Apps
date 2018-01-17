//
//  ContactListTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

protocol ContactListTableViewAdapterDelegate {
    func contactsLoaded(_ contacts: [CULContact])
    func selectionChanged(selectedContacts: [CULContact])
    func searchControllerSetupCompleted(_ searchController: UISearchController)
}

class ContactListTableViewAdapter: NSObject {
    
    private var contacts: [String: [CULContact]] = [:]
    private var allContacts: [CULContact] = []
    private var filteredContacts: [CULContact] = []
    private var selectedContacts: [CULContact] = []
    private var sortedKeys: [String] = []
    private var tableView: UITableView!
    private var searchController: UISearchController?
    private lazy var worker: ContactsWorker = ContactsWorker()
    var delegate: ContactListTableViewAdapterDelegate?
    
    func set(tableView: UITableView, with selectedContacts: [CULContact]) {
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.selectedContacts = selectedContacts
        self.selectionChanged()
        
        let nib: UINib = UINib(nibName: "ContactTblCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ContactTblCell")
        
        // Get list of all contacts from the user's phonebook
        self.worker.getContacts { (contacts, sortedKeys, error) in
            self.contacts = contacts
            self.sortedKeys = sortedKeys
            
            self.allContacts = []
            for key in self.contacts.keys {
                if let contactsTemp: [CULContact] = self.contacts[key] {
                    self.allContacts.append(contentsOf: contactsTemp)
                }
            }
            self.delegate?.contactsLoaded(self.allContacts)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func isContactSelected(_ contactToCheck: CULContact) -> Bool {
        if let _ = self.selectedContacts.index(where: { $0.identifier == contactToCheck.identifier }) {
            return true
        }
        return false
    }
    
    func addContactToSelected(_ selectedContact: CULContact) {
        self.selectedContacts.append(selectedContact)
        self.selectionChanged()
    }
    
    func removeContactFromSelected(_ contactToDeselect: CULContact) {
        if let index = self.selectedContacts.index(where: { $0.identifier == contactToDeselect.identifier }) {
            self.selectedContacts.remove(at: index)
            self.selectionChanged()
        }
    }
    
    func selectionChanged() {
        self.delegate?.selectionChanged(selectedContacts: self.selectedContacts)
    }
}

extension ContactListTableViewAdapter {
    
    func set(searchController: UISearchController) {
        self.searchController = searchController
    }
    
    //    func add(searchController: UISearchController) {
    //        self.searchController = searchController
    //    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredContacts = self.allContacts.filter({ (contact) -> Bool in
            return contact.name.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return self.searchController?.isActive ?? false && !self.searchBarIsEmpty()
    }
}

extension ContactListTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    private func getCultivateContact(for indexPath: IndexPath) -> CULContact {
        return self.contacts[self.sortedKeys[indexPath.section]]![indexPath.item]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFiltering() {
            return 1
        }
        return self.sortedKeys.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.isFiltering() {
            return []
        }
        return self.sortedKeys
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if self.isFiltering() {
            return 0
        }
        return self.sortedKeys.index(of: title) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isFiltering() {
            return ""
        }
        return self.sortedKeys[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isFiltering() {
            return 0.001
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredContacts.count
        }
        return self.contacts[self.sortedKeys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTblCell = tableView.dequeueReusableCell(withIdentifier: "ContactTblCell", for: indexPath) as! ContactTblCell
        var contact: CULContact!
        if self.isFiltering() {
            contact = self.filteredContacts[indexPath.item]
        } else {
            contact = self.getCultivateContact(for: indexPath)
        }
        cell.set(contact: contact)
        
        if self.isContactSelected(contact) {
            // Show selectction
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            // Remove selection
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var contact: CULContact!
        if self.isFiltering() {
            contact = self.filteredContacts[indexPath.item]
        } else {
            contact = self.getCultivateContact(for: indexPath)
        }
        if self.isContactSelected(contact) {
            // Deselect
            self.removeContactFromSelected(contact)
        } else {
            // Select
            self.addContactToSelected(contact)
        }
        tableView.reloadData()
    }
}

extension ContactListTableViewAdapter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}


