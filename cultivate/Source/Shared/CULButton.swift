//
//  CULButton.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class CULButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.adjustUI()
    }
    
    private func adjustUI() {
        self.addDropShadow()
        self.addBorder()
        self.addCornerRadius()
        self.setFont()
    }
    
    private func addDropShadow() {
        self.layer.shadowColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    private func addBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    }
    
    private func addCornerRadius() {
        self.layer.cornerRadius = 12
        self.clipsToBounds = false
    }
    
    private func setFont() {
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
}
