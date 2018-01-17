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

class ContactDetailsVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var valueViews: [UIView]!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameInitialsLabel: UILabel!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var callPhoneView: UIView!
    @IBOutlet weak var sendEmailView: UIView!
    @IBOutlet weak var callFaceTimeView: UIView!
    @IBOutlet weak var followupFrequencyValueButton: UIButton!
    @IBOutlet weak var tagValueButton: UIButton!
    @IBOutlet weak var nextFollowupDateValueButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    
    var contact: CULContact!
    
    private var reschedulePopupVC: ReschedulePopupVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius 
            = self.profileImageView.frame.width / 2
        
        for view in self.valueViews {
            self.addBorderAndBackground(to: view)
        }
        
        self.display(contact: self.contact)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.nameInitialsLabel.isHidden = true
        if let url = contact.profileImageURL {
            self.profileImageView.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
                if image == nil || error != nil {
                    self.show(nameInitials: contact.initials)
                }
            })
        } else {
            self.show(nameInitials: contact.initials)
        }
        
        self.nameLabel.text = contact.name
        self.followupFrequencyValueButton.setTitle(contact.followupFrequency.values.description, for: UIControlState.normal)
        self.tagValueButton.setTitle(contact.tag?.name ?? "None", for: UIControlState.normal)
        self.nextFollowupDateValueButton.setTitle(contact.userReadableFollowupDateString, for: .normal)
        self.notesTextView.text = contact.notes
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
        let worker = ContactsWorker()
        let numbers = worker.getPhoneNumbers(forContactIdentifier: self.contact.identifier)
        print(numbers)
        
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
        let worker = ContactsWorker()
        let numbers = worker.getPhoneNumbers(forContactIdentifier: self.contact.identifier)
        print(numbers)
        
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
        let worker = ContactsWorker()
        let emails = worker.getEmailAddresses(forContactIdentifier: self.contact.identifier)
        print(emails)
        
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
        let worker = ContactsWorker()
        
        let numbers = worker.getPhoneNumbers(forContactIdentifier: self.contact.identifier)
        let emails = worker.getEmailAddresses(forContactIdentifier: self.contact.identifier)
        
        print(numbers)
        
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
        
    }
    
    @IBAction func changeTagTapped(_ sender: UIButton) {
        
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
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: [self.contact], for: user, completion: { (error) in
                if let error = error {
                    self.showAlert("Error", message: error.localizedDescription)
                } else {
                    print("Notes updated")
                }
            })
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
