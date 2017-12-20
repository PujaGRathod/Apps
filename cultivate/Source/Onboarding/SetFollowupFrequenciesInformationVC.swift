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
        self.lblInformation.text = self.lblInformation.text?.replacingOccurrences(of: "<COUNT>", with: "\(self.selectedContacts.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowSetFollowupFrequenciesVC",
            let viewcontroller: SetFollowupFrequenciesVC = segue.destination as? SetFollowupFrequenciesVC {
            viewcontroller.contacts = self.selectedContacts
        }
    }

}
