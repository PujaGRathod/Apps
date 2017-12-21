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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forgotPasswordErrorLabel.text = ""
        self.forgotPasswordSuccessLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: CULButton) {
        if let email: String = self.txtEmail.text {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if error != nil {
                    self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
                    self.forgotPasswordErrorLabel.text = "Invalid email address"
                    self.forgotPasswordSuccessLabel.isHidden = true
                } else {
                    // Success
                    self.txtEmail.setTextfieldMode(to: CULTextFieldMode.success)
                    self.forgotPasswordErrorLabel.text = ""
                    self.forgotPasswordSuccessLabel.isHidden = false
                }
            })
        }
    }
}
