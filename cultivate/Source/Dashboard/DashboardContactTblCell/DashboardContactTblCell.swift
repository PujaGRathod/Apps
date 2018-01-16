//
//  DashboardContactTblCell.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class DashboardContactTblCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    
    private var contact: CULContact!
    
    var followupButtonTapped: ((CULContact)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contactNameLabel.text = "This is some long name. Really really long name."
        
        self.borderView.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 0.35)
        self.borderView.layer.borderWidth = 0.5
    }

    func set(contact: CULContact) {
        self.contact = contact
        
        self.contactNameLabel.text = contact.name
        
        self.dateLabel.text = contact.userReadableFollowupDateString
        self.dateLabel.textColor = self.color(for: contact.followupDate ?? Date())
    }
    
    private func color(for date: Date?) -> UIColor {
        guard let date = date else {
            return #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        }
        
        if date < Date() {
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    @IBAction func followupButtonTapped(_ sender: UIButton) {
        self.followupButtonTapped?(self.contact)
    }
}
