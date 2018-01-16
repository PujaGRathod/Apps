//
//  LogFollowupPopupVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 13/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup
import SZTextView

class LogFollowupPopupVC: UIViewController {
    
    @IBOutlet weak var sumbitButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var datePickerContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var detailsToRememberTextView: SZTextView!
    @IBOutlet weak var contactListTableView: UITableView!
    
    var followupDateUpdated: ((CULContact)->Void)?
    
    private var filteredContactList = [CULContact]()
    var allContacts = [CULContact]()
    var contact: CULContact! {
        didSet {
            self.showContactDetails(contact)
            if let date = self.contact.followupDate {
                self.datePicker.date = date
            }
        }
    }
    var presentingVC: UIViewController!
    var popup: KLCPopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 5
        self.dateTextField.inputView = self.datePickerContainerView
        self.datePicker.minimumDate = Date()
        
        self.setPlaceHolderForContactTextField()
        self.setPlaceHolderForDetailsTextField()
        
        self.dateTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.contactTextField.frame.height))
        self.dateTextField.rightViewMode = UITextFieldViewMode.always
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogFollowupPopupVC.contactTextDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.contactTextField)
        
        self.contactListTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.contactListTableView.rowHeight = 40
        self.contactListTableView.isHidden = true
        self.contactListTableView.delegate = self
        self.contactListTableView.dataSource = self
        
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                self.allContacts = contacts
            })
        }
        
        self.detailsToRememberTextView.becomeFirstResponder()
    }
    
    private func setPlaceHolderForContactTextField() {
        let text = "Contact name"
        let attributes: [NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5803921569, green: 0.5803921569, blue: 0.5803921569, alpha: 1)
        ]
        self.contactTextField.attributedPlaceholder = NSMutableAttributedString(string: text, attributes: attributes)
        
        self.contactTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.contactTextField.frame.height))
        self.contactTextField.leftViewMode = UITextFieldViewMode.always
    }
    
    private func setPlaceHolderForDetailsTextField() {
        let text = "What details of the conversation that you would like to remember?"
        let attributes: [NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5803921569, green: 0.5803921569, blue: 0.5803921569, alpha: 1)
        ]
        self.detailsToRememberTextView.attributedPlaceholder = NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    func viewForPopup() -> UIView {
        return self.containerView
    }
    
    @IBAction func datePickerDateChanged(_ sender: UIDatePicker) {
        self.contact.followupDate = sender.date
        self.dateTextField.text = contact.userReadableFollowupDateString
    }
    
    @IBAction func changeRescheduleButtonTapped(_ sender: UIButton) {
        self.dateTextField.becomeFirstResponder()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        self.showAlert("Under development", message: "Still working on this")
        
        //        self.contact.followupDate = self.datePicker.date
        //        if let user = CULFirebaseGateway.shared.loggedInUser {
        //            CULFirebaseGateway.shared.update(contacts: [self.contact], for: user, completion: { (error) in
        //                if let error = error {
        //                    self.showAlert("Error", message: error.localizedDescription)
        //                } else {
        //                    self.dateTextField.resignFirstResponder()
        //                    self.followupDateUpdated?()
        //                }
        //            })
        //        }
        //        self.popup.dismiss(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dateTextField.resignFirstResponder()
        self.popup.dismiss(true)
    }
    
    private func showContactDetails(_ contact: CULContact) {
        self.contactTextField.text = contact.name
        self.dateTextField.text = contact.userReadableFollowupDateString
    }
}


extension LogFollowupPopupVC {
    
    func isFiltering() -> Bool {
        return self.contactTextField.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredContactList = self.allContacts.filter({ (contact) -> Bool in
            return contact.name.lowercased().contains(searchText.lowercased())
        })
        self.contactListTableView.isHidden = !(self.filteredContactList.count > 0)
        self.contactListTableView.reloadData()
    }
    
    @objc func contactTextDidChange() {
        self.filterContentForSearchText(self.contactTextField.text ?? "")
    }
}

extension LogFollowupPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredContactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.filteredContactList[indexPath.item].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contact = self.filteredContactList[indexPath.item]
        self.showContactDetails(self.contact)
        self.contactListTableView.isHidden = true
    }
}
