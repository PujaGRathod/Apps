//
//  SetFollowupFrequenciesVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class SetFollowupFrequenciesVC: UIViewController {

    var contacts: [CULContact] = []
    private lazy var frequencyListTableViewAdapter: FollowupFrequencyListTableViewAdapter = FollowupFrequencyListTableViewAdapter()
    private var currentContact: CULContact! {
        didSet {
            self.frequencyListTableViewAdapter.set(contact: self.currentContact)
            self.setInformation(for: self.currentContact)
        }
    }
    
    @IBOutlet weak var lblContactCount: UILabel!
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var tblFrequencyList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getContacts()
        self.frequencyListTableViewAdapter.set(tableView: self.tblFrequencyList)
        self.frequencyListTableViewAdapter.delegate = self
        
        if let contact: CULContact = self.contacts.first {
            self.currentContact = contact
        } else {
            // FATAL ERROR
            // There's no contact to followup
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getContacts()
        self.tblFrequencyList.reloadData()
    }

    func getContacts() {
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
        } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            self.contacts = ContactSelectionProcessDataStore.shared.getNewContacts()
        }
    }
    
    func shouldPopViewController() -> Bool {
        if self.index(for: self.currentContact) == 0 {
            return true
        }
        
        // Set previous contact
        self.setContact(before: self.currentContact)
        return false
    }
    
    private func setInformation(for contact: CULContact) {
        self.lblContactName.text = contact.name
        
        if let index: Int = self.index(for: contact) {
            var middleString = ""
            if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
                middleString = " new"
            }
            self.lblContactCount.text = "\(index+1)/\(self.contacts.count)\(middleString) contacts"
        } else {
            self.printErrorMessageWhenContctIfNotFoundInTheList()
        }
    }
    
    func setContact(after contact: CULContact) {
        if let index: Int = self.index(for: contact) {
            let nextIndex: Int = index + 1
            if nextIndex == self.contacts.count {
                self.currentContact = self.contacts[index]
                // The contact is the last one on the list. We should move to the next screen now.
                if ContactSelectionProcessDataStore.shared.mode == .onboarding {
                    self.performSegue(withIdentifier: "segueShowAddTagsInformationVC", sender: nil)
                } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
                    self.performSegue(withIdentifier: "segueAddTags", sender: nil)
                }
            } else {
                self.currentContact = self.contacts[nextIndex]
            }
        } else {
            self.printErrorMessageWhenContctIfNotFoundInTheList()
        }
    }
    
    func setContact(before contact: CULContact) {
        if let index: Int = self.index(for: contact) {
            let previousIndex: Int = index - 1
            if previousIndex < 0 {
                // Pop the view controller
                self.navigationController?.popViewController(animated: true)
            } else {
                self.currentContact = self.contacts[previousIndex]
            }
        } else {
            self.printErrorMessageWhenContctIfNotFoundInTheList()
        }
    }
    
    func set(followupFrequency: CULFollowupFrequency, for contact: CULContact) {
        if let _ = self.index(for: contact) {
            var updatedContact = contact
            updatedContact.followupFrequency = followupFrequency
            if ContactSelectionProcessDataStore.shared.mode == .onboarding {
                ContactSelectionProcessDataStore.shared.update(contact: updatedContact)
                self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
            } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
                ContactSelectionProcessDataStore.shared.update(newContact: updatedContact)
                self.contacts = ContactSelectionProcessDataStore.shared.getNewContacts()
            }
        } else {
            self.printErrorMessageWhenContctIfNotFoundInTheList()
        }
    }
    
    private func index(for contact: CULContact) -> Int? {
        return self.contacts.index(where: { $0.identifier == contact.identifier })
    }
    
    private func printErrorMessageWhenContctIfNotFoundInTheList() {
        print("// Contact is not present in list. How could this happen?")
    }
}

extension SetFollowupFrequenciesVC: FollowupFrequencyListTableViewAdapterDelegate {
    func selected(frequency: CULFollowupFrequency, for contact: CULContact?) {
        if let contact = contact {
            self.set(followupFrequency: frequency, for: contact)
            self.setContact(after: contact)
        }
    }
}
