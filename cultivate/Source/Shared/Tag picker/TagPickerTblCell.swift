//
//  TagPickerTblCell.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class TagPickerTblCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(tag: CULTag, isSelected: Bool) {
        self.titleLabel.textColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.text = tag.name
        self.checkmarkImageView.isHidden = !isSelected
    }
    
}
