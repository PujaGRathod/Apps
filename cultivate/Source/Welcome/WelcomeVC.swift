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
        
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
        }
    }
}
