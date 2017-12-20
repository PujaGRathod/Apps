//
//  WelcomeVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit

class WelcomeVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var btnContinueWithEmail: UIButton!
    @IBOutlet weak var btnContinueWithFacebook: FBSDKLoginButton!
    @IBOutlet weak var viewContinueWithGoogle: GIDSignInButton!
    @IBOutlet weak var viewFooter: FooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        self.removeConstraints()

        self.btnContinueWithFacebook.readPermissions = ["public_profile", "email"]
        self.btnContinueWithFacebook.delegate = self
        
        self.btnContinueWithEmail.layer.borderWidth = 1
        self.btnContinueWithEmail.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        self.btnContinueWithEmail.layer.cornerRadius = 5
        
        //        self.btnContinueWithFacebook.layer.borderWidth = 1
        //        self.btnContinueWithFacebook.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        self.btnContinueWithFacebook.layer.cornerRadius = 5

        //        self.viewContinueWithGoogle.layer.borderWidth = 1
        //        self.viewContinueWithGoogle.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        self.viewContinueWithGoogle.layer.cornerRadius = 5

        self.viewFooter.setCurrentStep(to: OnboardingStep.createAccount)
    }
    
    func removeConstraints() {
        for constraint in self.btnContinueWithFacebook.constraints {
            if constraint.constant == 28 && constraint.firstAttribute == NSLayoutAttribute.height {
                self.btnContinueWithFacebook.removeConstraint(constraint)
            }
        }
        
        for constraint in self.viewContinueWithGoogle.constraints {
            print(constraint.constant)
            if constraint.constant == 48 && constraint.firstAttribute == NSLayoutAttribute.height {
                self.viewContinueWithGoogle.removeConstraint(constraint)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.removeConstraints()
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
    
    @IBAction func googleSigninButtonTapped() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google account disconnected: \(user.profile.email) with error:\(error.localizedDescription)")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Error with google signin: \(error.localizedDescription)")
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        self.authenticateUser(with: credential, name: user.profile.name, email: user.profile.email)
    }

    func authenticateUser(with credential: AuthCredential, name: String, email: String) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                if let error = error as? NSError,
                    let name = error.userInfo["error_name"] as? String {
                    if name == "ERROR_EMAIL_ALREADY_IN_USE" || name == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
                        self.showAlert("Error", message: error.localizedDescription)
                    }
                }
                print("Error FIR AUTH: \(error.localizedDescription)")
                self.signoutUser()
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
            } else {
                print("user is new")
                let user = CULUser(withName: name, email: email, id: id)
                user.save()
            }
        })
    }

    func signoutUser() {
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }

}

extension WelcomeVC: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result.isCancelled {
            print("Cancelled by user!")
        } else {
            print("Permissions: \(result.grantedPermissions)")
            print("UserID: \(result.token.userID)")
            if let profileRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "email, id, name"]) {
                profileRequest.start(completionHandler: { (connection, result, error) in
                    if let error = error {
                        print("Error Profile fetching: \(error.localizedDescription)")
                    } else {
                        if let result = result as? [String: Any?] {
                            print("email from FB: \(String(describing: result["email"]))")
                            let email = result["email"] as? String
                            let name = result["name"] as? String
                            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                            self.authenticateUser(with: credential, name: name ?? "", email: email ?? "")
                        } else {
                            print("Wrong response: \(String(describing: result))")
                        }
                    }
                })
            }
        }

    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }

}
