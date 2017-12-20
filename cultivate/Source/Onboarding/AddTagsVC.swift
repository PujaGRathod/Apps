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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagListTableViewAdapter.set(tableView: self.tblTagsList)
        self.tagListTableViewAdapter.delegate = self
        
        self.txtAddNewTag.delegate = self
        
        if let contact: CULContact = self.contacts.first {
            self.currentContact = contact
        } else {
            // FATAL ERROR
            // There's no contact to followup
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblTagsList.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            self.lblContactCount.text = "\(index+1)/\(self.contacts.count)"
        } else {
            self.printErrorMessageWhenContctIfNotFoundInTheList()
        }
    }
    
    func setContact(after contact: CULContact) {
        if let index: Int = self.index(for: contact) {
            let nextIndex: Int = index + 1
            if nextIndex == self.contacts.count {
                // The contact is the last one on the list. We should move to the next screen now.
                self.performSegue(withIdentifier: "segueShowOnboardingCompletedVC", sender: self.contacts)
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
    
    func set(tag: CULTag, for contact: CULContact) {
        if let index: Int = self.index(for: contact) {
            contact.tag = tag
            self.contacts[index] = contact
            
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func add(tag name: String) -> CULTag {
        return self.tagListTableViewAdapter.add(tag: name)
    }
}

extension AddTagsVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: Trim characters
        if let text: String = textField.text {
            if self.tagListTableViewAdapter.filteredTagsCount() == 0 {
                let tag: CULTag = self.add(tag: text)
                self.set(tag: tag, for: self.currentContact)
                self.setContact(after: self.currentContact)
            }
        } else {
            // TODO: Show empty textfield error
        }
        return true
    }
}

extension AddTagsVC: TagsListTableViewAdapterDelegate {
    func selected(tag: CULTag, for contact: CULContact) {
        self.set(tag: tag, for: contact)
        self.setContact(after: contact)
    }
}
