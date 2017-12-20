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
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRetypePassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textfields: [UITextField] = [ self.txtEmail, self.txtPassword, self.txtRetypePassword ]
        for textfield in textfields {
            textfield.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
            textfield.layer.borderWidth = 1
        }
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
        if let emailText = self.txtEmail.text,
            emailText.isValidEmail() {
            if let passText = self.txtPassword.text,
                let repassText = self.txtRetypePassword.text {
                if passText == repassText {
                    self.signupUser(with: emailText, password: passText, name: "")
                } else {
                    self.showAlert("Error!", message: "Password do not match!")
                }
            } else {
                self.showAlert("Required!", message: "Password is required!")
            }
        } else {
            self.showAlert("Required!", message: "Valid Email is required!")
        }
    }

    func signupUser(with email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                if let error = error as? NSError,
                    let name = error.userInfo["error_name"] as? String {
                    if name == "ERROR_EMAIL_ALREADY_IN_USE" || name == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
                        self.showAlert("Error", message: "The email address is already in use by another account.")
                    }
                }
                print("Error FIR AUTH: \(error.localizedDescription)")
                self.signoutUser()
                return
            }
            if let user = user {
                print("User account created with: \(email)")
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
