//
//  CULTextField.swift
//  cultivate
//
//  Created by Akshit Zaveri on 21/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

enum CULTextFieldMode {
    case success
    case error
}

class CULTextField: UITextField {
    
    private var errorBorderColor: UIColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
    private var successBorderColor: UIColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
    
    private var errorBackgroundColor: UIColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.1)
    private var successBackgroundColor: UIColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
    
    private var errorFontColor: UIColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
    private var successFontColor: UIColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
    
    private var currentMode: CULTextFieldMode = CULTextFieldMode.success
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    private func setupUI() {
        self.setBorder()
        self.setCornerRadius()
        self.setBackgroundColor()
        self.setLeftMargin()
        self.setFontColor()
    }
    
    private func setBorder() {
        self.layer.borderWidth = 1
        switch self.currentMode {
        case .success:
            self.layer.borderColor = self.successBorderColor.cgColor
        case .error:
            self.layer.borderColor = self.errorBorderColor.cgColor
        }
    }
    
    private func setCornerRadius() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = false
    }
    
    private func setBackgroundColor() {
        switch self.currentMode {
        case .success:
            self.backgroundColor = self.successBackgroundColor
        case .error:
            self.backgroundColor = self.errorBackgroundColor
        }
    }
    
    private func setFontColor() {
        switch self.currentMode {
        case .success:
            self.textColor = self.successFontColor
        case .error:
            self.textColor = self.errorFontColor
        }
    }
    
    private func setLeftMargin() {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.height))
        self.leftViewMode = UITextFieldViewMode.always
    }
    
    func setTextfieldMode(to newMode: CULTextFieldMode) {
        self.currentMode = newMode
        self.setBorder()
        self.setBackgroundColor()
        self.setFontColor()
    }
    
    func isPasswordStrong() -> Bool {
        if let text: String = self.text, text.count >= 8 {
            if self.hasLowercaseCharacters(),
                self.hasUppercaseCharacters(),
                self.hasSymbols(),
                self.hasNumbers() {
                return true
            }
        }
        return false
    }
    
    private func hasLowercaseCharacters() -> Bool {
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        if self.text?.rangeOfCharacter(from: set) != nil {
            return true
        }
        return false
    }
    
    private func hasUppercaseCharacters() -> Bool {
        let set = CharacterSet(charactersIn: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        if self.text?.rangeOfCharacter(from: set) != nil {
            return true
        }
        return false
    }
    
    private func hasSymbols() -> Bool {
        let set = CharacterSet(charactersIn: "!@#$%^&*()~{}[]:\";',./<>?")
        if self.text?.rangeOfCharacter(from: set) != nil {
            return true
        }
        return false
    }
    
    private func hasNumbers() -> Bool {
        let set = CharacterSet(charactersIn: "0123456789")
        if self.text?.rangeOfCharacter(from: set) != nil {
            return true
        }
        return false
    }
}
