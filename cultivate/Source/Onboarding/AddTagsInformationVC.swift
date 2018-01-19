//
//  AddTagsInformationVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class AddTagsInformationVC: UIViewController {

    var contacts: [CULContact] = []
    
    @IBOutlet weak var footerView: FooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.footerView.setCurrentStep(to: OnboardingStep.addTags)
        self.contacts = ContactSelectionProcessDataStore.shared.getContacts()
    }

}
