//
//  OnboardinDataStore.swift
//  cultivate
//
//  Created by Akshit Zaveri on 17/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation

class ContactSelectionProcessDataStore {
    
    enum Mode {
        case onboarding
        case updatingContacts
    }
    
    static let shared = ContactSelectionProcessDataStore()
    
    private var selectedContacts = [CULContact]()
    var mode: Mode?
    private var newContacts = [CULContact]()
    
    func empty() {
        self.selectedContacts = []
    }
    
    func setNewContacts(from allContacts: [CULContact]) {
        var contacts = [CULContact]()
        for contact in allContacts {
            if contact.db_Identifier == nil {
                contacts.append(contact)
            }
        }
        self.newContacts = contacts
    }
    
    func getNewContacts() -> [CULContact] {
        return self.newContacts
    }
    
    func update(contacts: [CULContact]) -> [CULContact] {
        if self.selectedContacts.count == 0 {
            self.selectedContacts = contacts
        } else {
            var updatedSelection = [CULContact]()
            for contact in contacts {
                if let filterdContact = self.selectedContacts.filter({ $0.identifier == contact.identifier }).first {
                    updatedSelection.append(filterdContact)
                } else {
                    updatedSelection.append(contact)
                }
            }
            self.selectedContacts = updatedSelection
        }
        self.sortContacts()
        return self.selectedContacts
    }
    
    func update(newContact: CULContact) {
        for (index, selectedContact) in self.newContacts.enumerated() {
            if newContact.identifier == selectedContact.identifier {
                self.newContacts[index] = newContact
                break
            }
        }
    }
    
    func update(contact: CULContact) {
        for (index, selectedContact) in self.selectedContacts.enumerated() {
            if contact.identifier == selectedContact.identifier {
                self.selectedContacts[index] = contact
                break
            }
        }
    }
    
    private func sortContacts() {
        let sortOrder = ContactsWorker().getSortOrder()
        self.selectedContacts.sort(by: { (contact1, contact2) -> Bool in
            switch sortOrder {
            case .familyName:
                if let lastName1 = contact1.last_name, let lastName2 = contact2.last_name {
                    return lastName1 < lastName2
                }
            case .givenName:
                if let firstName1 = contact1.first_name, let firstName2 = contact2.first_name {
                    return firstName1 < firstName2
                }
            }
            return contact1.name < contact2.name
        })
        print("Sorted list: \(self.selectedContacts))")
    }
    
    func getContacts() -> [CULContact] {
        return self.selectedContacts
    }
}
