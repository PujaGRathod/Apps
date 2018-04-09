//
//  FrequencyPickerTblCell.swift
//  cultivate
//
//  Created by Akshit Zaveri on 17/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class FrequencyPickerTblCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(frequency: CULFollowupFrequency, isSelected: Bool) {
        self.titleLabel.text = frequency.values.description
        self.checkmarkImageView.isHidden = !isSelected
    }
    
}
