//
//  LoginVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

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

    }
}
