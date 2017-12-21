//
//  SignupVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupVC: UIViewController {

    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var txtEmail: CULTextField!
    @IBOutlet weak var txtPassword: CULTextField!
    @IBOutlet weak var txtRetypePassword: CULTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.errorLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onSignupTap(_ sender: UIButton) {
        let email: String? = self.txtEmail.text
        let password: String? = self.txtPassword.text
        let retypePassword: String? = self.txtRetypePassword.text
        
        var errorMessages: [String] = []
        
        var validationSuccess: Bool = true
        
        if email?.isEmpty == true {
            self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
            errorMessages.append("E-mail address can not be empty")
            validationSuccess = false
        } else {
            if email?.isValidEmail() == false {
                self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
                errorMessages.append("E-mail address is not valid")
                validationSuccess = false
            } else {
                self.txtEmail.setTextfieldMode(to: CULTextFieldMode.success)
            }
        }
        
        if password?.isEmpty == true || retypePassword?.isEmpty == true || password != retypePassword {
            errorMessages.append("Password and Re-type password does not match")
            self.txtPassword.setTextfieldMode(to: CULTextFieldMode.error)
            self.txtRetypePassword.setTextfieldMode(to: CULTextFieldMode.error)
            validationSuccess = false
        } else {
            if self.txtPassword.isPasswordStrong() {
                self.txtPassword.setTextfieldMode(to: CULTextFieldMode.success)
                self.txtRetypePassword.setTextfieldMode(to: CULTextFieldMode.success)
            } else {
                errorMessages.append("Your password must be at least 8 characters")
                self.txtPassword.setTextfieldMode(to: CULTextFieldMode.error)
                self.txtRetypePassword.setTextfieldMode(to: CULTextFieldMode.error)
                validationSuccess = false
            }
        }
        
        if validationSuccess {
            self.errorLabel.text = ""
            self.signupUser(with: email!, password: password!, name: "")
        } else {
            self.errorLabel.text = errorMessages.joined(separator: "\n")
        }
    }

    func signupUser(with email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                if let error = error as? NSError,
                    let name = error.userInfo["error_name"] as? String {
                    if name == "ERROR_EMAIL_ALREADY_IN_USE" || name == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
                        self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
                        self.errorLabel.text = "The email address is already in use by another account."
                    }
                }
                print("Error FIR AUTH: \(error.localizedDescription)")
                self.signoutUser()
                return
            }
            if let user = user {
                print("User account created with: \(email)")
                // TODO: Open onboarding
                self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
                let userlocal = CULUser(withName: name, email: user.email ?? email, id: user.uid)
                userlocal.save()
            } else {
                print("Error: user is nil FIR AUTH")
            }
        }
    }

    func signoutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
