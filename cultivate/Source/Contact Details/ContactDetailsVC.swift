//
//  ContactDetailsVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 13/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class ContactDetailsVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var valueViews: [UIView]!
    
    var contact: CULContact!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius 
            = self.profileImageView.frame.width / 2
        
        for view in self.valueViews {
            self.addBorderAndBackground(to: view)
        }
    }

    private func addBorderAndBackground(to view: UIView) {
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        view.layer.borderWidth = 1
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            self.scrollView.setContentOffset(self.historyTableView.frame.origin, animated: true)
        default:
            self.scrollView.setContentOffset(self.detailView.frame.origin, animated: true)
        }
    }
}
