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

class WelcomeVC: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var btnContinueWithEmail: CULButton!
    @IBOutlet weak var btnContinueWithFacebook: FBSDKLoginButton!
    @IBOutlet weak var viewContinueWithGoogle: GIDSignInButton!
    @IBOutlet weak var viewFooter: FooterView!
    @IBOutlet weak var lblTermsPrivacyPolicyAgreement: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        self.removeConstraints()
        
//        self.btnContinueWithFacebook.layer.borderWidth = 1
//        self.btnContinueWithFacebook.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
//        self.btnContinueWithFacebook.layer.cornerRadius = 5
//
//        self.viewContinueWithGoogle.layer.borderWidth = 1
//        self.viewContinueWithGoogle.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
//        self.viewContinueWithGoogle.layer.cornerRadius = 5
        
        self.viewFooter.setCurrentStep(to: OnboardingStep.createAccount)
        
        self.setupPrivacyAndTermsLabelWithLinks()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowWebLinkVC",
            let navController: UINavigationController = segue.destination as? UINavigationController,
            let viewcontroller: WebLinkVC = navController.viewControllers.first as? WebLinkVC {
            viewcontroller.webLinkOption = sender as? WebLinkOptions
        }
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
