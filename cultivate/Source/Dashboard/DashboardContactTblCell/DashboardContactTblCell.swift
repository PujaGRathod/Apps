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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    
    private var contact: CULContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contactNameLabel.text = "This is some long name. Really really long name."
        
        self.containerView.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 0.35)
        self.containerView.layer.borderWidth = 1
    }

    func set(contact: CULContact) {
        self.contact = contact
        
        self.contactNameLabel.text = contact.name
        
        self.dateLabel.text = self.userReadableString(from: contact.followupDate ?? Date())
        self.dateLabel.textColor = self.color(for: contact.followupDate ?? Date())
    }
    
    private func userReadableString(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        return dateformatter.string(from: date)
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
        
    }
}
