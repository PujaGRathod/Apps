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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowAddTagsVC", let viewcontroller: AddTagsVC = segue.destination as? AddTagsVC {
            viewcontroller.contacts = self.contacts
        }
    }

}
