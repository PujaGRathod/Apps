//
//  AddTagsVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class AddTagsVC: UIViewController {
    
    var contacts: [CULContact] = []
    private lazy var tagListTableViewAdapter: TagsListTableViewAdapter = TagsListTableViewAdapter()
    private var currentContact: CULContact! {
        didSet {
            self.tagListTableViewAdapter.set(contact: self.currentContact)
            self.setInformation(for: self.currentContact)
        }
    }
    
    @IBOutlet weak var lblContactCount: UILabel!
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var txtAddNewTag: UITextField!
    @IBOutlet weak var tblTagsList: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var skipButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagListTableViewAdapter.set(tableView: self.tblTagsList)
        self.tagListTableViewAdapter.delegate = self
        self.tagListTableViewAdapter.textField = self.txtAddNewTag
        self.tagListTableViewAdapter.loadAllAvailableTags()
        
        self.tblTagsList.tableHeaderView = self.headerView
        
        self.getContacts()
        
        self.txtAddNewTag.delegate = self
        
        self.skipButtonBottomConstraint.constant = -62
        if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            self.skipButtonBottomConstraint.constant = 12
        } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
            let menuButton = UIBarButtonItem()
            menuButton.image = #imageLiteral(resourceName: "ic_menu")
            self.navigationItem.leftBarButtonItem = menuButton
            hamburgerMenuVC.configure(menuButton, view: self.view)
        }
        self.view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getContacts()
        self.tblTagsList.reloadData()
    }
    
    func getContacts() {
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
            self.setCurrentContact()
        } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            self.contacts = ContactSelectionProcessDataStore.shared.getNewContacts()
            self.setCurrentContact()
        } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
            if let user = CULFirebaseGateway.shared.loggedInUser {
                CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                    DispatchQueue.main.async {
                        self.showContactsWithMissingTags(contacts)
                        self.setCurrentContact()
                    }
                })
            }
        }
    }
    
    private func setCurrentContact() {
        if let contact: CULContact = self.contacts.first {
            self.currentContact = contact
        } else {
            // FATAL ERROR
            // There's no contact to followup
        }
    }
    
    private func showContactsWithMissingTags(_ contacts: [CULContact]) {
        self.contacts = contacts.filter({ (contact) -> Bool in
            if contact.tag == nil {
                return true
            } else if contact.tag?.identifier == nil {
                return true
            }
            return false
        })
        ContactSelectionProcessDataStore.shared.contactsWithMissingTags = self.contacts
        self.tblTagsList.reloadData()
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        print(self.txtAddNewTag.text ?? "N.A")
        if let text: String = self.txtAddNewTag.text {
            self.tagListTableViewAdapter.search(tag: text)
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
            if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
                middleString = " contact\((self.contacts.count > 1) ? "s":"") with no tag"
            }
            self.lblContactCount.text = "\(index+1)/\(self.contacts.count)\(middleString)"
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
                    _ = ContactSelectionProcessDataStore.shared.update(contacts: self.contacts)
                } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
                    ContactSelectionProcessDataStore.shared.setNewContacts(from: self.contacts)
                } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
                    ContactSelectionProcessDataStore.shared.contactsWithMissingTags = self.contacts
                }
                self.performSegue(withIdentifier: "segueShowOnboardingCompletedVC", sender: nil)
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
    
    func set(tag: CULTag?, for contact: CULContact) {
        if let _ = self.index(for: contact) {
            var updatedContact = contact
            updatedContact.tag = tag
            if ContactSelectionProcessDataStore.shared.mode == .onboarding {
                ContactSelectionProcessDataStore.shared.update(contact: updatedContact)
                self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
            } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
                ContactSelectionProcessDataStore.shared.update(newContact: updatedContact)
                self.contacts = ContactSelectionProcessDataStore.shared.getNewContacts()
            } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
                ContactSelectionProcessDataStore.shared.update(contactWithMissingTag: updatedContact)
                self.contacts = ContactSelectionProcessDataStore.shared.contactsWithMissingTags
            }
            
            self.txtAddNewTag.text = nil
            self.tagListTableViewAdapter.search(tag: "")
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
    
    func add(tag name: String, completion: @escaping ((CULTag?)->Void))  {
        self.tagListTableViewAdapter.add(tag: name, completion: completion)
    }
}

extension AddTagsVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: Trim characters
        if let text: String = textField.text {
            if self.tagListTableViewAdapter.filteredTagsCount() == 0 {
                self.add(tag: text, completion: { (tag) in
                    if let tag = tag {
                        self.set(tag: tag, for: self.currentContact)
                        self.setContact(after: self.currentContact)
                    }
                })
            }
        } else {
            // TODO: Show empty textfield error
        }
        return true
    }
}

extension AddTagsVC: TagsListTableViewAdapterDelegate {
    
    func tagsLoaded(_ tags: [CULTag]) {
        
    }
    
    func selected(tag: CULTag?, for contact: CULContact?) {
        self.set(tag: tag, for: self.currentContact)
        self.setContact(after: self.currentContact)
    }
}
