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
        
        // Upload contacts to the user
        
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let store: Firestore = Firestore.firestore()
        
        let batch: WriteBatch = store.batch()
        
        for contact in self.contacts {
            let data: [String:Any] = self.convertContactToRawData(contact)
            let ref = store.collection("users").document(currentUser.uid).collection("contacts").document()
            batch.setData(data, forDocument: ref)
        }
        
        let ref = store.collection("users").document(currentUser.uid)
        batch.updateData([ "isOnBoardingComplete" : true ], forDocument: ref)

        batch.commit { (error) in
            if let error = error {
                // Error
                self.showAlert("Error", message: error.localizedDescription)
            } else {
                // Success
                self.dataUploaded = true
                if self.userTappedOnButton == true {
                    self.performSegue(withIdentifier: "segueDashboard", sender: nil)
                }
            }
        }
        
    }
    
    private func convertContactToRawData(_ contact: CULContact) -> [String:Any] {
        var raw: [String:Any] = [:]
        
        raw["identifier"] = contact.identifier
        
        if let first_name = contact.first_name {
            raw["first_name"] = first_name
        }

        if let last_name = contact.last_name {
            raw["last_name"] = last_name
        }
        
        raw["followupFrequency"] = contact.followupFrequency.rawValue
        
        if let tagId = contact.tag?.identifier {
            raw["tag"] = tagId
        }
        
        return raw
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
