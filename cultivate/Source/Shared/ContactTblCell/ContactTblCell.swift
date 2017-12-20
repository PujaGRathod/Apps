//
//  ContactTblCell.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class ContactTblCell: UITableViewCell {
    
    @IBOutlet weak var lblContactName: UILabel!
    private var contact: CULContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(contact: CULContact) {
        self.contact = contact
        
        self.lblContactName.text = contact.name
    }
}
