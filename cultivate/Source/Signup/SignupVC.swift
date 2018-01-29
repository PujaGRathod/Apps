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
                errorMessages.append("Your password must be at least 8 characters and consist of at least one lowercase, one uppercase, one number and one symbol.")
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
                let error = error as NSError
                if let name = error.userInfo["error_name"] as? String {
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
//                if let email = user.email {
//                    user.sendEmailVerification(completion: { (error) in
//                        self.showAlert("Sent", message: "A verification email has been sent at \(email). Please check your inbox.")
//                        self.createCULUserAndShowOnboarding(name: name, email: email, id: user.uid)
//                    })
//                } else {
                    self.createCULUserAndShowOnboarding(name: name, email: email, id: user.uid)
//                }
            } else {
                print("Error: user is nil FIR AUTH")
            }
        }
    }
    
    private func createCULUserAndShowOnboarding(name: String, email: String, id: String) {
        
        if let currentUser = Auth.auth().currentUser {
            CULUser.checkIfUserExist(with: currentUser.uid, completion: { (loggedInUser, success) in
                CULFirebaseGateway.shared.loggedInUser = loggedInUser
            })
        }
        
        CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.accountCreationDate, value: Date())
        CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.email, value: email)
        CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.name, value: name)
        print("User account created with: \(email)")
        let userlocal = CULUser(withName: name, email: email, id: id)
        userlocal.save()
        
        DispatchQueue.main.async {
            // Open onboarding
            self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
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
