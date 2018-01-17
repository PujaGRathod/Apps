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
    
    private var dataUploaded: Bool = false
    private var userTappedOnButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.footerView.setProgressCompletion()
        
        self.contacts = OnboardingDataStore.shared.getContacts()
        
        // Upload contacts to the user
        if let user = CULFirebaseGateway.shared.loggedInUser {
            self.uploadData(for: user)
        }
        
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
        
        group.enter()
        CULFirebaseGateway.shared.setOnboardingCompleted(for: user) { (error) in
            if let error = error {
                // Error
                self.showAlert("Error", message: error.localizedDescription)
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            // Success
            self.dataUploaded = true
            if self.userTappedOnButton == true {
                self.performSegue(withIdentifier: "segueDashboard", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueDashboard" {
            self.userTappedOnButton = true
            if self.dataUploaded == false {
                return false
            }
        }
        return true
    }
}
