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
import Instructions

class LogFollowupPopupVC: UIViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var datePickerContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var detailsToRememberTextView: SZTextView!
    @IBOutlet weak var contactListTableView: UITableView!
    
    var followupLogged: ((_ contact: CULContact)->Void)?
    
    private var coachMarksController = CoachMarksController()
    private var filteredContactList = [CULContact]()
    var allContacts = [CULContact]()
    var contact: CULContact?
    var presentingVC: UIViewController!
    var popup: KLCPopup!
    
    private var isDateChangedManually = false
    
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
        
        let calendar = Calendar(identifier: .gregorian)
        var datecomps = calendar.dateComponents([.day,.month,.year], from: Date())
        if let year = datecomps.year {
            datecomps.year = year + 1
            datecomps.month = 12
            datecomps.day = 31
        }
        self.datePicker.maximumDate = calendar.date(from: datecomps)
    }
    
    func showHelpPopovers() {
        if self.shouldShowHelp() {
            self.didShowHelp()
            self.coachMarksController.dataSource = self
            self.coachMarksController.start(on: self)
        }
    }
    
    private func shouldShowHelp() -> Bool {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            return !user.isFollowupHintsShown
        }
        return false
    }
    
    private func didShowHelp() {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.loggedInUser?.isFollowupHintsShown = true
            CULFirebaseGateway.shared.setFollowupHintsShown(for: user, completion: { (error) in
            })
        }
    }
    
    func loadContactDetails() {
        let date = self.contact?.followupFrequency.values.dateByAddingComponentsTo(Date())
        self.contact?.followupDate = date
        self.showContactDetails(contact)
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
        self.contact?.followupDate = sender.date
        self.dateTextField.text = self.contact?.userReadableFollowupDateString
        self.isDateChangedManually = true
    }
    
    @IBAction func changeRescheduleButtonTapped(_ sender: UIButton) {
        self.dateTextField.becomeFirstResponder()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        let id = CULFirebaseAnalyticsManager.Keys.Identifiers.followup.rawValue
        var name = CULFirebaseAnalyticsManager.Keys.Actions.submit.rawValue
        if self.detailsToRememberTextView.text.isEmpty {
            name += CULFirebaseAnalyticsManager.Keys.Actions.submitWithEmptyNote.rawValue
        }
        if self.isDateChangedManually {
            name += CULFirebaseAnalyticsManager.Keys.Actions.submitWithManualDate.rawValue
        }
        let contentType = CULFirebaseAnalyticsManager.Keys.ContentTypes.followup.rawValue
        CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
        
        var followup = CULContact.Followup()
        followup.date = Date()
        followup.notes = self.detailsToRememberTextView.text
        if let user = CULFirebaseGateway.shared.loggedInUser, let contact = self.contact {
            sender.isEnabled = false
            CULFirebaseGateway.shared.addNew(followup: followup, for: contact, loggedInUser: user) { (error) in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        sender.isEnabled = true
//                        self.showAlert("Error", message: error.localizedDescription)
//                    } else {
//                        self.updateNextFollowupDate(for: contact, loggedInUser: user)
//                        self.popup.dismiss(true)
//                    }
//                }
            }
            self.updateNextFollowupDate(for: contact, loggedInUser: user)
            self.popup.dismiss(true)
        }
    }
    
    private func updateNextFollowupDate(for contact: CULContact, loggedInUser: CULUser) {
        CULFirebaseGateway.shared.update(contacts: [contact], for: loggedInUser) { (error) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.showAlert("Error", message: error.localizedDescription)
//                } else {
//
//                }
//
//            }
        }
        self.dateTextField.resignFirstResponder()
        self.followupLogged?(contact)
        self.popup.dismiss(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dateTextField.resignFirstResponder()
        self.popup.dismiss(true)
    }
    
    private func showContactDetails(_ contact: CULContact?) {
        if var contact = contact {
            self.contactTextField.text = contact.name
            if let date = contact.followupDate {
                self.datePicker.date = date
            } else {
                self.datePicker.date = Date()
            }
            contact.followupDate = self.datePicker.date
            self.dateTextField.text = contact.userReadableFollowupDateString
        } else {
            self.contactTextField.text = ""
            self.datePicker.date = Date()
            self.dateTextField.text = ""
        }
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
        self.submitButton.isEnabled = true
        self.loadContactDetails()
        self.contactListTableView.isHidden = true
    }
}

extension LogFollowupPopupVC: UITextFieldDelegate {

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
        self.submitButton.isEnabled = false
        self.filterContentForSearchText(self.contactTextField.text ?? "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.contactTextField.text = self.contact?.name
    }
}

extension LogFollowupPopupVC: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        if index == 0 {
            return coachMarksController.helper.makeCoachMark(for: self.detailsToRememberTextView)
        } else {
            return coachMarksController.helper.makeCoachMark(for: self.dateTextField)
        }
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: false, arrowOrientation: coachMark.arrowOrientation)

        var hintText = ""
        if index == 0 {
            hintText = "Impress your friends by remembering important details from your conversations."
        } else {
            hintText = "Cultivate automatically calculates the next follow-up date based on your preferred follow-up frequency for the contact.\n\nYou can manually set the next follow-up by selecting the date"
        }
        coachViews.bodyView.hintLabel.text = hintText
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
}

//extension LogFollowupPopupVC: UIPopoverPresentationControllerDelegate {
//
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
//}

