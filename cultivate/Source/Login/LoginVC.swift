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

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if let emailText = self.txtEmail.text,
            emailText.isValidEmail() {
            if let passText = self.txtPassword.text {
                let credntial = EmailAuthProvider.credential(withEmail: emailText, password: passText)
                self.authenticateUser(with: credntial, name: "", email: emailText)
            } else {
                self.showAlert("Required!", message: "Password is required!")
            }
        } else {
            self.showAlert("Required!", message: "Valid Email is required!")
        }
    }


    func authenticateUser(with credential: AuthCredential, name: String, email: String) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error FIR AUTH: \(error.localizedDescription)")
                self.showAlert("Error", message: error.localizedDescription)
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
                print("User account created with: \(credential.provider)")
                self.checkandCreateUser(id: user.uid, email: user.email ?? email, name: user.displayName ?? name)
            } else {
                print("Error: user is nil FIR AUTH")
            }
        }
    }

    func checkandCreateUser(id: String, email: String, name: String) {
        CULUser.checkIfUserExist(with: id, completion: { (fetchedUser, exist)  in
            if exist && fetchedUser != nil {
                print("user is old")
                self.showAlert("Success", message: "Login success")
            } else {
                print("user is new")
                // TODO: Open onboarding
                self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
                let user = CULUser(withName: name, email: email, id: id)
                user.save()
            }
        })
    }

}
