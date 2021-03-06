//
//  OnboardingCompletedVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase

class OnboardingCompletedVC: UIViewController {
    
    var contacts: [CULContact] = []
    
    @IBOutlet weak var footerView: FooterView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var finishButton: CULButton!
    
    //    private var dataUploaded: Bool = false
    private var userTappedOnButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.footerView.setProgressCompletion()
        
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
        } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            self.contacts = ContactSelectionProcessDataStore.shared.getNewContacts()
            self.titleLabel.isHidden = false
            self.messageLabel.text = "You've finished editing your Inner circle."
            self.finishButton.setTitle("Finish", for: .normal)
            self.footerView.isHidden = true
        } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
            self.contacts = ContactSelectionProcessDataStore.shared.contactsWithMissingTags
            self.titleLabel.isHidden = false
            self.messageLabel.text = "You've finished adding tags."
            self.finishButton.setTitle("Finish", for: .normal)
            self.footerView.isHidden = true
        }
        
        // Upload contacts to the user
        if let user = CULFirebaseGateway.shared.loggedInUser {
            self.uploadData(for: user)
        }
        
    }
    
    func shouldPopViewController() -> Bool {
        return false
    }
    
    func uploadData(for user: CULUser) {
        let group = DispatchGroup()
        
        group.enter()
        if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
            CULFirebaseGateway.shared.update(contacts: self.contacts, for: user, completion: { (error) in
                if let error = error {
                    // Error
                    self.showAlert("Error", message: error.localizedDescription)
                }
                group.leave()
            })
        } else {
            CULFirebaseGateway.shared.addNew(contacts: self.contacts, for: user) { (error) in
                print("New contacts added")
                CULFirebaseGateway.shared.getContacts(for: user, { (latestContacts) in
                    print("Contacts fetched added")
                    for (index, contact) in self.contacts.enumerated() {
                        if let latestContact = latestContacts.filter({ $0.identifier == contact.identifier }).first {
                            self.contacts[index] = latestContact
                        }
                    }
                    self.updateContacts {
                        print("Contacts updated")
                        group.leave()
                    }
                })
                
                
                if let error = error {
                    // Error
                    self.showAlert("Error", message: error.localizedDescription)
                }
            }
        }
        
        
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            group.enter()
            CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.onboardingCompletionDate, value: "yes")
            CULFirebaseGateway.shared.setOnboardingCompleted(for: user) { (error) in
                if let error = error {
                    // Error
                    self.showAlert("Error", message: error.localizedDescription)
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            // Success
            //            self.dataUploaded = true
            if self.userTappedOnButton == true {
                CULFirebaseGateway.shared.deleteUnusedTags()
                self.showNextVC()
            }
        }
    }
    
    func updateContacts(_ completion: @escaping (()->Void)) {
        // Generate initial followup dates for all contacts
        self.contacts = FollowupDateGenerator.assignInitialFollowupDates(for: self.contacts)
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: self.contacts, for: user, completion: { (error) in
                print("Contacts saved - OnboardingCompletedVC")
                completion()
            })
        }
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        self.userTappedOnButton = true
        //        if self.dataUploaded == true {
        self.showNextVC()
        //        }
    }
    
    private func showNextVC() {
        
        ContactSelectionProcessDataStore.shared.empty()
        
        var id = ""
        var name = ""
        
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            id = "Onboarding"
            name = "Completion"

            self.performSegue(withIdentifier: "segueDashboard", sender: nil)
        } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            id = "UpdatingContacts"
            name = "Completion"
            
            let id = "SUBMIT"
            let name = "FINISH_BUTTON_EDIT_CONTACTS"
            CULFirebaseAnalyticsManager.shared.logUserSelection(with: id, on: name)
            
            self.navigationController?.popToRootViewController(animated: true)
        } else if ContactSelectionProcessDataStore.shared.mode == .addMissingTags {
            id = "AddMissingTags"
            name = "Completion"
            
            let id = "SUBMIT"
            let name = "FINISH_BUTTON_ADD_MISSING_TAGS"
            CULFirebaseAnalyticsManager.shared.logUserSelection(with: id, on: name)
            
            self.performSegue(withIdentifier: "segueDashboard", sender: nil)
        }
        
        CULFirebaseAnalyticsManager.shared.logUserSelection(with: id, on: name)
    }
}
