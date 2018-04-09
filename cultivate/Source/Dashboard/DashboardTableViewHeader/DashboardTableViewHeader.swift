//
//  DashboardTableViewHeader.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class DashboardTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    private var index: Int?
    var headerTapped: ((_ index: Int?)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont.italicSystemFont(ofSize: 13)
        self.button.titleLabel?.font = UIFont.italicSystemFont(ofSize: 13)
        
        self.button.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.button.layer.shadowRadius = 2
        self.button.layer.shadowOpacity = 1
        self.button.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func set(title: String, index: Int) {
        self.titleLabel.text = title
        self.index = index
    }
    
    func setButtonVisibility(to visible: Bool) {
        self.titleLabel.isHidden = visible
        self.bottomSeparatorView.isHidden = visible
        self.button.isHidden = !visible
    }
    
    @IBAction func headerTapped(_ sender: UIButton) {
        self.headerTapped?(index)
    }
}
