//
//  SetFollowupFrequenciesInformationVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class SetFollowupFrequenciesInformationVC: UIViewController {

    var selectedContacts: [CULContact] = []
    
    @IBOutlet weak var footerView: FooterView!
    @IBOutlet weak var lblInformation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.footerView.setCurrentStep(to: OnboardingStep.setPriorityLevels)
        
        self.selectedContacts = ContactSelectionProcessDataStore.shared.getContacts()
        
        self.lblInformation.text = self.lblInformation.text?.replacingOccurrences(of: "<COUNT>", with: "\(self.selectedContacts.count)")
        
        if self.selectedContacts.count > 1 {
            self.lblInformation.text = self.lblInformation.text?.replacingOccurrences(of: "<PLURAL-LETTER>", with: "s")
        } else {
            self.lblInformation.text = self.lblInformation.text?.replacingOccurrences(of: "<PLURAL-LETTER>", with: "")
        }
    }
}
