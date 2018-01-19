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
    
    private var dataUploaded: Bool = false
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
        CULFirebaseGateway.shared.addNew(contacts: self.contacts, for: user) { (error) in
            if let error = error {
                // Error
                self.showAlert("Error", message: error.localizedDescription)
            }
            group.leave()
        }
        
        
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            group.enter()
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
            self.dataUploaded = true
            if self.userTappedOnButton == true {
                self.nextVC()
            }
        }
    }
    
    private func nextVC() {
        if ContactSelectionProcessDataStore.shared.mode == .onboarding {
            self.performSegue(withIdentifier: "segueDashboard", sender: nil)
        } else if ContactSelectionProcessDataStore.shared.mode == .updatingContacts {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        self.userTappedOnButton = true
        if self.dataUploaded == true {
            self.nextVC()
        }
    }
}
