//
//  ContactDetailsVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 13/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import SDWebImage
import MessageUI
import KLCPopup
import ContactsUI

class ContactDetailsVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var valueViews: [UIView]!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameInitialsLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var imgViewMessage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sendMessageView: UIView!
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var imgViewPhone: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var callPhoneView: UIView!
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var sendEmailView: UIView!
    @IBOutlet weak var imgViewEmail: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var faceTimeButton: UIButton!
    @IBOutlet weak var callFaceTimeView: UIView!
    @IBOutlet weak var imgViewFaceTime: UIImageView!
    @IBOutlet weak var faceTimeLabel: UILabel!
    
    @IBOutlet weak var followupFrequencyValueButton: UIButton!
    @IBOutlet weak var tagValueButton: UIButton!
    @IBOutlet weak var nextFollowupDateValueButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    
    var contact: CULContact!
    private var frequencyPickerPopupVC: FrequencyPickerPopupVC?
    private var tagPickerPopupVC: TagPickerPopupVC?
    private var reschedulePopupVC: ReschedulePopupVC?
    private var historyTableViewAdapter = ContactLogHistoryTableViewAdapter()
    private var emailAddresses = [String:String]()
    private var phoneNumbers = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius 
            = self.profileImageView.frame.width / 2
        
        for view in self.valueViews {
            self.addBorderAndBackground(to: view)
        }
        
        self.showHUD(on: self.historyTableView, with: "Loading...")
        self.historyTableViewAdapter.historyLoaded = {
            self.hideHUD(for: self.historyTableView)
        }
        self.historyTableViewAdapter.set(tableView: self.historyTableView, contact: self.contact)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.display(contact: self.contact)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactDetailsVC.notesTextEditingDidEnd), name:  NSNotification.Name.UITextViewTextDidEndEditing, object: self.notesTextView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: self.notesTextView)
    }

    private func addBorderAndBackground(to view: UIView) {
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        view.layer.borderWidth = 1
    }
    
    private func display(contact: CULContact) {
        self.loadProfileImage(for: contact)
        self.nameLabel.text = contact.name
        self.followupFrequencyValueButton.setTitle(contact.followupFrequency.values.description, for: UIControlState.normal)
        self.tagValueButton.setTitle(contact.tag?.name ?? "None", for: UIControlState.normal)
        self.nextFollowupDateValueButton.setTitle(contact.userReadableFollowupDateString, for: .normal)
        self.notesTextView.text = contact.notes
        self.getEmailAddresses()
        self.getPhoneNumbers()
        self.setVisibilityOfViewsForEmailAndPhoneNumbers()
    }
    
    private func setVisibilityOfViewsForEmailAndPhoneNumbers() {
        
        var arePhoneNumbersAvailable = false
        if self.phoneNumbers.keys.count > 0 {
            arePhoneNumbersAvailable = true
        }
        
        var areEmailAddressesAvailable = false
        if self.emailAddresses.keys.count > 0 {
            areEmailAddressesAvailable = true
        }
        
        self.emailLabel.isHighlighted = areEmailAddressesAvailable
        self.imgViewEmail.isHighlighted = areEmailAddressesAvailable
        self.emailButton.isUserInteractionEnabled = areEmailAddressesAvailable
        
        self.messageLabel.isHighlighted = arePhoneNumbersAvailable
        self.imgViewMessage.isHighlighted = arePhoneNumbersAvailable
        self.messageButton.isUserInteractionEnabled = arePhoneNumbersAvailable
        
        self.phoneLabel.isHighlighted = arePhoneNumbersAvailable
        self.imgViewPhone.isHighlighted = arePhoneNumbersAvailable
        self.phoneButton.isUserInteractionEnabled = arePhoneNumbersAvailable
        
        let isFaceTimeAvailable = (arePhoneNumbersAvailable || areEmailAddressesAvailable)
        self.faceTimeLabel.isHighlighted = isFaceTimeAvailable
        self.imgViewFaceTime.isHighlighted = isFaceTimeAvailable
        self.faceTimeButton.isUserInteractionEnabled = isFaceTimeAvailable
    }
    
    private func getEmailAddresses() {
        let worker = ContactsWorker()
        self.emailAddresses = worker.getEmailAddresses(forContactIdentifier: self.contact.identifier)
    }
    
    private func getPhoneNumbers() {
        let worker = ContactsWorker()
        self.phoneNumbers = worker.getPhoneNumbers(forContactIdentifier: self.contact.identifier)
    }
    
    func loadProfileImage(for contact: CULContact) {
        self.nameInitialsLabel.isHidden = true
        if let image = ContactsWorker().getThumbnailImage(forContactIdentifier: contact.identifier) {
            self.profileImageView.image = image
//        } else if let url = contact.profileImageURL {
//            self.profileImageView.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
//                if image == nil || error != nil {
//                    self.show(nameInitials: contact.initials)
//                }
//            })
        } else {
            self.show(nameInitials: contact.initials)
        }
    }
    
    private func show(nameInitials: String) {
        self.nameInitialsLabel.isHidden = false
        self.nameInitialsLabel.text = nameInitials
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            self.scrollView.setContentOffset(self.historyTableView.frame.origin, animated: true)
        default:
            self.scrollView.setContentOffset(self.detailView.frame.origin, animated: true)
        }
    }
    
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        
        let numbers = self.phoneNumbers
        
        let actionSheet = UIAlertController(title: "Choose", message: "Tap a number to message", preferredStyle: UIAlertControllerStyle.actionSheet)
        for key in numbers.keys {
            guard let number = numbers[key] else {
                continue
            }
            let title = "\(key): \(number)"
            let handler: ((UIAlertAction)->Void) = { (action) in
                guard let num = number.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
                    return
                }
                
                if MFMessageComposeViewController.canSendText() == false {
                    return
                }
                
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.recipients = [num]
                composeVC.body = ""
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
                
            }
            actionSheet.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: handler))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            print("Cancelled calling")
        }))
        self.present(actionSheet, animated: true) {
        }
    }
    
    @IBAction func callPhoneButtonTapped(_ sender: UIButton) {

        let numbers = self.phoneNumbers
        
        let actionSheet = UIAlertController(title: "Choose", message: "Tap a number to call", preferredStyle: UIAlertControllerStyle.actionSheet)
        for key in numbers.keys {
            guard let number = numbers[key] else {
                continue
            }
            let title = "\(key): \(number)"
            let handler: ((UIAlertAction)->Void) = { (action) in
                guard let num = number.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
                    return
                }
                guard let url = URL(string: "tel:\(num)") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: { (finished) in
                })
            }
            actionSheet.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: handler))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            print("Cancelled calling")
        }))
        self.present(actionSheet, animated: true) {
        }
    }
    
    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {

        let emails = self.emailAddresses
        
        let actionSheet = UIAlertController(title: "Choose", message: "Tap an email address", preferredStyle: UIAlertControllerStyle.actionSheet)
        for key in emails.keys {
            guard let email = emails[key] else {
                continue
            }
            let title = "\(key): \(email)"
            let handler: ((UIAlertAction)->Void) = { (action) in
                
                if MFMailComposeViewController.canSendMail() == false {
                    return
                }
                
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setToRecipients([ email ])
                self.present(mailComposer, animated: true, completion: {
                })
            }
            actionSheet.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: handler))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
        }))
        self.present(actionSheet, animated: true) {
        }
    }
    
    @IBAction func callFaceTimeButtonTapped(_ sender: UIButton) {
        
        let numbers = self.phoneNumbers
        let emails = self.emailAddresses
        
        let actionSheet = UIAlertController(title: "Choose", message: "Tap a number to FaceTime", preferredStyle: UIAlertControllerStyle.actionSheet)
        for key in numbers.keys {
            guard let number = numbers[key] else {
                continue
            }
            let title = "\(key): \(number)"
            let handler: ((UIAlertAction)->Void) = { (action) in
                guard let num = number.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
                    return
                }
                guard let url = URL(string: "facetime:\(num)") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: { (finished) in
                })
            }
            actionSheet.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: handler))
        }
        for key in emails.keys {
            guard let email = emails[key] else {
                continue
            }
            let title = "\(key): \(email)"
            let handler: ((UIAlertAction)->Void) = { (action) in
                guard let email = email.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
                    return
                }
                guard let url = URL(string: "facetime:\(email)") else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: { (finished) in
                })
            }
            actionSheet.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: handler))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            print("Cancelled facetime call")
        }))
        self.present(actionSheet, animated: true) {
        }
    }
    
    @IBAction func changeFollowupFrequencyTapped(_ sender: UIButton) {
        self.showFrequencyPicker(for: self.contact)
    }
    
    @IBAction func changeTagTapped(_ sender: UIButton) {
        self.showTagPicker(for: self.contact)
    }
    
    @IBAction func changeFollowupDateTapped(_ sender: UIButton) {
        self.reschedulePopup(for: contact)
    }

    private func reschedulePopup(for contact: CULContact) {
        self.reschedulePopupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReschedulePopupVC") as? ReschedulePopupVC
        if let reschedulePopupVC = self.reschedulePopupVC {
            reschedulePopupVC.followupDateUpdated = { updatedContact in
                self.contact.followupDate = updatedContact.followupDate
                self.display(contact: self.contact)
            }
            reschedulePopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            reschedulePopupVC.contact = contact
            reschedulePopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(reschedulePopupVC.view)
            
            let verticalLayout = KLCPopupVerticalLayout.aboveCenter
            let layout = KLCPopupLayout(horizontal: .center, vertical: verticalLayout)
            
            let contentView = reschedulePopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            reschedulePopupVC.popup = popup
            if let popup = popup {
                popup.show(with: layout)
            }
        }
    }
    
    @objc private func notesTextEditingDidEnd() {
        self.contact.notes = self.notesTextView.text
        self.update(contact: self.contact)
    }
    
    private func update(contact: CULContact) {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: [contact], for: user, completion: { (error) in
                if let error = error {
                    self.showAlert("Error", message: error.localizedDescription)
                } else {
                    print("Contact updated")
                }
            })
        }
    }

    func showFrequencyPicker(for contact: CULContact?) {
        self.frequencyPickerPopupVC = self.storyboard?.instantiateViewController(withIdentifier: "FrequencyPickerPopupVC") as? FrequencyPickerPopupVC
        if let frequencyPickerPopupVC = self.frequencyPickerPopupVC {
            frequencyPickerPopupVC.frequencyUpdated = { updatedFrequency in
                self.contact.followupFrequency = updatedFrequency
                self.display(contact: self.contact)
                self.update(contact: self.contact)
            }
            frequencyPickerPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            frequencyPickerPopupVC.selectedFrequency = contact?.followupFrequency
            frequencyPickerPopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(frequencyPickerPopupVC.view)
            
            let contentView = frequencyPickerPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            frequencyPickerPopupVC.popup = popup
            if let popup = popup {
                popup.show(with: KLCPopupLayoutCenter)
            }
            frequencyPickerPopupVC.validateSubmitButton()
        }
    }
    
    func showTagPicker(for contact: CULContact?) {
        self.tagPickerPopupVC = self.storyboard?.instantiateViewController(withIdentifier: "TagPickerPopupVC") as? TagPickerPopupVC
        if let tagPickerPopupVC = self.tagPickerPopupVC {
            tagPickerPopupVC.tagUpdated = { updatedTag in
                self.contact.tag = updatedTag
                self.display(contact: self.contact)
                self.update(contact: self.contact)
            }
            tagPickerPopupVC.shouldShowAddNewTagTextField = true
            tagPickerPopupVC.view.translatesAutoresizingMaskIntoConstraints = false
            tagPickerPopupVC.presentingVC = self
            // Ugly hack to force system to load the UIView
            print(tagPickerPopupVC.view)
            
            let contentView = tagPickerPopupVC.viewForPopup()
            let popup = KLCPopup(contentView: contentView, showType: .slideInFromTop, dismissType: .slideOutToTop, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
            tagPickerPopupVC.popup = popup
            tagPickerPopupVC.set(tag: contact?.tag)
        }
    }

    @IBAction func detailsButtonTapped(_ sender: UIBarButtonItem) {
        if let contact = ContactsWorker().getCNContact(for: self.contact.identifier) {
            let vc = CNContactViewController(for: contact)
            vc.delegate = self
            vc.allowsActions = true
            vc.contactStore = ContactsWorker().getContactStore()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ContactDetailsVC: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
        }
    }
}

extension ContactDetailsVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
        }
    }
}

extension ContactDetailsVC: CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true) {
        }
    }
}
