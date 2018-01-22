//
//  ContactHistoryTblCell.swift
//  cultivate
//
//  Created by Akshit Zaveri on 17/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class ContactHistoryTblCell: UITableViewCell {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var notesBackgroudView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.circleView.layer.cornerRadius = self.circleView.frame.width / 2
        
        self.notesBackgroudView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.notesBackgroudView.layer.shadowRadius = 2
        self.notesBackgroudView.layer.shadowOpacity = 1
        self.notesBackgroudView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        self.notesBackgroudView.layer.borderColor = #colorLiteral(red: 0.8196078431, green: 0.8078431373, blue: 0.8078431373, alpha: 1)
        self.notesBackgroudView.layer.borderWidth = 1
    }
    
    func set(followup: CULContact.Followup) {
        self.dateLabel.text = followup.userReadableDateString
        self.notesLabel.text = followup.notes
        self.notesBackgroudView.isHidden = (followup.notes?.count == 0) ? true : false
    }
}
