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
import TTTAttributedLabel

class WelcomeVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var continueWithEmailContainerView: UIView!
    @IBOutlet weak var continueWithFacebookContainerView: UIView!
    @IBOutlet weak var continueWithGoogleContainerView: UIView!
    @IBOutlet weak var btnContinueWithEmail: CULButton!
    @IBOutlet weak var btnContinueWithFacebook: CULButton!
//    @IBOutlet weak var viewContinueWithGoogle: GIDSignInButton!
    @IBOutlet weak var continueWithGoogleButton: CULButton!
    @IBOutlet weak var lblTermsPrivacyPolicyAgreement: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        self.removeConstraints()

//        self.btnContinueWithFacebook.readPermissions = ["public_profile", "email"]
//        self.btnContinueWithFacebook.delegate = self
        
        self.setupPrivacyAndTermsLabelWithLinks()
        
//        self.btnContinueWithFacebook.titleLabel?.font = self.btnContinueWithEmail.titleLabel?.font
        
        self.continueWithEmailContainerView.layer.cornerRadius = self.btnContinueWithEmail.layer.cornerRadius
        self.continueWithEmailContainerView.layer.borderColor = self.btnContinueWithEmail.layer.borderColor
        self.continueWithEmailContainerView.layer.borderWidth = self.btnContinueWithEmail.layer.borderWidth
        
        self.continueWithFacebookContainerView.layer.cornerRadius = self.btnContinueWithEmail.layer.cornerRadius
        self.continueWithFacebookContainerView.layer.borderColor = self.btnContinueWithEmail.layer.borderColor
        self.continueWithFacebookContainerView.layer.borderWidth = self.btnContinueWithEmail.layer.borderWidth
        
        self.continueWithGoogleContainerView.layer.cornerRadius = self.btnContinueWithEmail.layer.cornerRadius
        self.continueWithGoogleContainerView.layer.borderColor = self.btnContinueWithEmail.layer.borderColor
        self.continueWithGoogleContainerView.layer.borderWidth = self.btnContinueWithEmail.layer.borderWidth
    }
    
    private func setupPrivacyAndTermsLabelWithLinks() {
        if let text: String = self.lblTermsPrivacyPolicyAgreement.text {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text)
            
            let attributesForFullString: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3803921569, green: 0.368627451, blue: 0.3843137255, alpha: 1).cgColor
            ]
            let rangeOfString: NSRange = NSRange.init(location: 0, length: text.count)
            attributedString.addAttributes(attributesForFullString, range: rangeOfString)
            
            let attributesForLinks: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3803921569, green: 0.368627451, blue: 0.3843137255, alpha: 1).cgColor,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            let rangeTermsString: NSRange = (text as NSString).range(of: "Terms of Service")
            attributedString.addAttributes(attributesForLinks, range: rangeTermsString)
            let rangePrivacyString: NSRange = (text as NSString).range(of: "Privacy Policy")
            attributedString.addAttributes(attributesForLinks, range: rangePrivacyString)
            
            self.lblTermsPrivacyPolicyAgreement.linkAttributes = attributesForLinks
            
            let attributesForActiveLinks: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1).cgColor,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            self.lblTermsPrivacyPolicyAgreement.activeLinkAttributes = attributesForActiveLinks
            
            self.lblTermsPrivacyPolicyAgreement.delegate = self
            self.lblTermsPrivacyPolicyAgreement.setText(attributedString)
            
            self.lblTermsPrivacyPolicyAgreement.addLink(to: WebLinkOptions.termsOfService.values.link, with: rangeTermsString)
            self.lblTermsPrivacyPolicyAgreement.addLink(to: WebLinkOptions.privacyPolicy.values.link, with: rangePrivacyString)
        } else {
            // Display error
        }
    }
    
    func removeConstraints() {
//        for constraint in self.btnContinueWithFacebook.constraints {
//            if constraint.constant == 28 && constraint.firstAttribute == NSLayoutAttribute.height {
//                self.btnContinueWithFacebook.removeConstraint(constraint)
//            }
//        }
        
//        for constraint in self.viewContinueWithGoogle.constraints {
//            print(constraint.constant)
//            if constraint.constant == 48 && constraint.firstAttribute == NSLayoutAttribute.height {
//                self.viewContinueWithGoogle.removeConstraint(constraint)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeConstraints()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowWebLinkVC",
            let navController: UINavigationController = segue.destination as? UINavigationController,
            let viewcontroller: WebLinkVC = navController.viewControllers.first as? WebLinkVC {
            viewcontroller.webLinkOption = sender as? WebLinkOptions
        }
    }
    
//    @IBAction func googleSigninButtonTapped() {
//
//        GIDSignIn.sharedInstance().signIn()
//    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google account disconnected: \(user.profile.email) with error:\(error.localizedDescription)")
        self.hideHUD()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.hideHUD()
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
                self.hideHUD()
                let error = error as NSError
                if let name = error.userInfo["error_name"] as? String {
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
                
//                if let email = user.email {
//                    user.sendEmailVerification(completion: { (error) in
//                        self.showAlert("Sent", message: "A verification email has been sent at \(email). Please check your inbox.")
//                        self.createCULUserAndShowOnboarding(name: name, email: email, id: user.uid)
//                    })
//                } else {
//                    self.createCULUserAndShowOnboarding(name: name, email: email, id: user.uid)
//                }
                
                print("User account created with: \(credential.provider)")
                self.checkandCreateUser(id: user.uid, email: user.email ?? email, name: user.displayName ?? name)
            } else {
                self.hideHUD()
                print("Error: user is nil FIR AUTH")
            }
        }
    }

    func checkandCreateUser(id: String, email: String, name: String) {
        CULUser.checkIfUserExist(with: id, completion: { (fetchedUser, exist)  in
            if exist && fetchedUser != nil {
                
                print("user is old")
                CULFirebaseGateway.shared.loggedInUser = fetchedUser
                if fetchedUser?.isOnBoardingComplete == true {
                    // Show dashboard
                    self.performSegue(withIdentifier: "segueDashboard", sender: nil)
                } else {
                    // Show onboarding
                    self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
                }
            } else {
                print("user is new")
                self.performSegue(withIdentifier: "segueShowOnboarding", sender: nil)
                let user = CULUser(withName: name, email: email, id: id)
                user.save()
                CULFirebaseGateway.shared.loggedInUser = user
            }
            self.hideHUD()
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

    @IBAction func continueWithGoogleTapped(_ sender: UIButton) {
        self.showHUD(with: "Logging you in...")
        GIDSignIn.sharedInstance().signIn()
    }
}

extension WelcomeVC:TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var webLinkOption: WebLinkOptions?
        if url == WebLinkOptions.privacyPolicy.values.link {
            webLinkOption = WebLinkOptions.privacyPolicy
        } else if url == WebLinkOptions.termsOfService.values.link {
            webLinkOption = WebLinkOptions.termsOfService
        }
        self.performSegue(withIdentifier: "segueShowWebLinkVC", sender: webLinkOption)
    }
}

extension WelcomeVC: FBSDKLoginButtonDelegate {
    
    @IBAction func loginWithFacebookButtonTapped(_ sender: UIButton) {
        self.showHUD(with: "Logging you in...")
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            guard let result = result else {
                return
            }
            
            if result.isCancelled {
                self.hideHUD()
                print("Cancelled by user!")
            } else {
                print("Permissions: \(result.grantedPermissions)")
                print("UserID: \(result.token.userID)")
                if let profileRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "email, id, name"]) {
                    profileRequest.start(completionHandler: { (connection, result, error) in
                        if let error = error {
                            self.hideHUD()
                            print("Error Profile fetching: \(error.localizedDescription)")
                        } else {
                            if let result = result as? [String: Any?] {
                                print("email from FB: \(String(describing: result["email"]))")
                                let email = result["email"] as? String
                                let name = result["name"] as? String
                                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                self.authenticateUser(with: credential, name: name ?? "", email: email ?? "")
                            } else {
                                self.hideHUD()
                                print("Wrong response: \(String(describing: result))")
                            }
                        }
                    })
                }
            }
            
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result.isCancelled {
            self.hideHUD()
            print("Cancelled by user!")
        } else {
            print("Permissions: \(result.grantedPermissions)")
            print("UserID: \(result.token.userID)")
            if let profileRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "email, id, name"]) {
                profileRequest.start(completionHandler: { (connection, result, error) in
                    if let error = error {
                        self.hideHUD()
                        print("Error Profile fetching: \(error.localizedDescription)")
                    } else {
                        if let result = result as? [String: Any?] {
                            print("email from FB: \(String(describing: result["email"]))")
                            let email = result["email"] as? String
                            let name = result["name"] as? String
                            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                            self.authenticateUser(with: credential, name: name ?? "", email: email ?? "")
                        } else {
                            self.hideHUD()
                            print("Wrong response: \(String(describing: result))")
                        }
                    }
                })
            }
        }

    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.hideHUD()
    }

}
