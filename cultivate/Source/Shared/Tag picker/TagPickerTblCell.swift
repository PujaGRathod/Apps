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
        self.titleLabel.text = tag.name
        self.checkmarkImageView.isHidden = !isSelected
    }
    
}
