//
//  ReschedulePopupVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 13/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup


class ReschedulePopupVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var datePickerContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    
    var followupDateUpdated: ((CULContact)->Void)?
    
    var contact: CULContact!{
        didSet {
            if let date = self.contact.followupDate {
                self.dateTextField.text = self.contact.userReadableFollowupDateString
                self.datePicker.date = date
            } else {
                //TODO: Assign a followup date if not found
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
        self.dateTextField.becomeFirstResponder()
    }
    
    func viewForPopup() -> UIView {
        return self.containerView
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        self.contact.followupDate = self.datePicker.date
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: [self.contact], for: user, completion: { (error) in
                if let error = error {
                    self.showAlert("Error", message: error.localizedDescription)
                } else {
                    self.dateTextField.resignFirstResponder()
                    self.followupDateUpdated?(self.contact)
                }
            })
        }
        self.popup.dismiss(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dateTextField.resignFirstResponder()
        self.popup.dismiss(true)
    }
    
    @IBAction func datePickerDateChanged(_ sender: UIDatePicker) {
        self.contact.followupDate = self.datePicker.date
        self.dateTextField.text = self.contact.userReadableFollowupDateString
    }
    
    @IBAction func changeRescheduleButtonTapped(_ sender: UIButton) {
        self.dateTextField.becomeFirstResponder()
    }
}
