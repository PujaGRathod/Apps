//
//  ForgotPasswordVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: CULTextField!
    @IBOutlet weak var forgotPasswordSuccessLabel: UILabel!
    @IBOutlet weak var forgotPasswordErrorLabel: UILabel!
    @IBOutlet weak var submitButton: CULButton!
    @IBOutlet weak var forgotPasswordContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        self.forgotPasswordErrorLabel.text = ""
        self.forgotPasswordSuccessLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: CULButton) {
        self.txtEmail.resignFirstResponder()
        self.submitButton.isUserInteractionEnabled = false
        if let email: String = self.txtEmail.text {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                DispatchQueue.main.async {
                    self.forgotPasswordResponse(error: error)
                }
            })
        }
    }
    
    private func forgotPasswordResponse(error: Error?) {
        if error != nil {
            self.submitButton.isHidden = false
            self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
            self.forgotPasswordErrorLabel.text = "Invalid email address"
            self.forgotPasswordSuccessLabel.isHidden = true
            self.submitButton.isUserInteractionEnabled = true
        } else {
            // Success
            self.txtEmail.setTextfieldMode(to: CULTextFieldMode.success)
            self.forgotPasswordErrorLabel.text = ""
            self.forgotPasswordSuccessLabel.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.submitButton.alpha = 0
            }, completion: { (finished) in
                self.submitButton.isHidden = true
            })
        }
    }
}
