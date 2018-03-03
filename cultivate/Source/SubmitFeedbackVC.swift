//
//  SubmitFeedbackVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import SZTextView

class SubmitFeedbackVC: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textView: SZTextView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var submitButton: CULButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        self.textView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        self.textView.layer.borderWidth = 1
        self.textView.layer.cornerRadius = 5
        
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
        
        self.successLabel.isHidden = true
        self.successLabel.alpha = 0
    }
    
    @IBAction func submitButtonTapped(_ sender: CULButton) {
        if self.textView.text.isEmpty == false {
            self.textView.resignFirstResponder()
            
            let id = "Feedback"
            let name = "Feedback"
            let contentType = "Submit"
            CULFirebaseAnalyticsManager.shared.log(id: id, itemName: name, contentType: contentType)
            
            if let user = CULFirebaseGateway.shared.loggedInUser {
                self.showSuccessLabel()
                CULFirebaseGateway.shared.submit(feedback: self.textView.text, for: user, { (error) in
                    //                    self.submitFeedbackResponse(with: error)
                })
            }
        }
    }
    
    //    private func submitFeedbackResponse(with error: Error?) {
    //        DispatchQueue.main.async {
    //            if error == nil {
    //                self.showSuccessLabel()
    //            } else {
    //                self.showAlert("Error", message: "There was a problem while submitting your feedback. Please try again later. If the problem persist, contact the developer.")
    //            }
    //        }
    //    }
    
    private func showSuccessLabel() {
        self.successLabel.isHidden = false
        UIView.animate(withDuration: 0.27, animations: {
            self.successLabel.alpha = 1
            self.textView.alpha = 0
            self.submitButton.alpha = 0
        }) { (finished) in
            if finished {
                self.textView.isHidden = true
                self.submitButton.isHidden = true
            }
        }
    }
    
}
