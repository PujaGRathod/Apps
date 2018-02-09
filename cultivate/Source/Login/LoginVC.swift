//
//  LoginVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var txtEmail: CULTextField!
    @IBOutlet weak var txtPassword: CULTextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.text = ""
        let textfields: [UITextField] = [ self.txtEmail, self.txtPassword]
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

    @IBAction func onLoginTap(_ sender: UIButton) {
        let email: String? = self.txtEmail.text
        let password: String? = self.txtPassword.text
        
        var errorMessages: [String] = []
        
        var validationSuccess: Bool = true
        
        if email?.isEmpty == true {
            self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
            errorMessages.append("E-mail address can not be empty")
            validationSuccess = false
        } else {
            if email?.isValidEmail() == false {
                self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
                errorMessages.append("E-mail address is not valid.")
                validationSuccess = false
            } else {
                self.txtEmail.setTextfieldMode(to: CULTextFieldMode.success)
            }
        }
        
        if password?.isEmpty == true {
            errorMessages.append("Password can not be empty")
            self.txtPassword.setTextfieldMode(to: CULTextFieldMode.error)
            validationSuccess = false
        } else {
            self.txtPassword.setTextfieldMode(to: CULTextFieldMode.success)
        }
        
        if validationSuccess {
            self.txtPassword.resignFirstResponder()
            self.txtEmail.resignFirstResponder()
            
            self.errorLabel.text = ""
            let credntial = EmailAuthProvider.credential(withEmail: email!, password: password!)
            self.authenticateUser(with: credntial, name: "", email: email!)
        } else {
            self.errorLabel.text = errorMessages.joined(separator: "\n")
        }
    }


    func authenticateUser(with credential: AuthCredential, name: String, email: String) {
        self.showHUD(with: "Logging in")
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.hideHUD()
                print("Error FIR AUTH: \(error.localizedDescription)")
                self.txtEmail.setTextfieldMode(to: CULTextFieldMode.error)
                self.txtPassword.setTextfieldMode(to: CULTextFieldMode.error)
                self.errorLabel.text = "Invalid password or e-mail address."
                return
            }
            if let user = user {
                if user.email == nil {
                    user.updateEmail(to: email, completion: { (error) in
                        print("Error while updating email: \(error?.localizedDescription ?? "nil")")
                    })
                } else {
                    print("Email on FIR User: \(user.email ?? "nil")")
                }
                print("User account logged in with: \(credential.provider)")
                self.checkandCreateUser(id: user.uid, email: user.email ?? email, name: user.displayName ?? name)
            } else {
                self.hideHUD()
                print("Error: user is nil FIR AUTH")
            }
        }
    }

    func checkandCreateUser(id: String, email: String, name: String) {
        CULUser.checkIfUserExist(with: id, completion: { (fetchedUser, exist)  in
            
            CULFirebaseGateway.shared.loggedInUser = fetchedUser
            
            self.hideHUD()
            
            if exist && fetchedUser != nil {
                print("user is old")
                if fetchedUser?.isOnBoardingComplete == true {
                    // Show dashboard
                    self.performSegue(withIdentifier: "segueDashboard", sender: nil)
                } else {
                    // Show onboarding
                    self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
                }
            } else {
                print("user is new")
                let user = CULUser(withName: name, email: email, id: id)
                user.save()
                
                // Open onboarding
                self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
            }
        })
    }

}
