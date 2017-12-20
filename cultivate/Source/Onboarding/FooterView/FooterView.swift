//
//  FooterView.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

enum OnboardingStep {
    case createAccount
    case chooseContacts
    case setPriorityLevels
    case addTags
}

class FooterView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var stepViewsCollection: [UIView]!
    @IBOutlet var stepInnerCircleCollection: [UIView]!
    @IBOutlet weak var innerViewCreateAccount: UIView!
    @IBOutlet weak var innerViewChooseContacts: UIView!
    @IBOutlet weak var innerViewPriorityLevels: UIView!
    @IBOutlet weak var innerViewAddTags: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        
        // align contentView from the left and right
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.contentView]));
        
        // align contentView from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.contentView]));
        
        self.layoutIfNeeded()
        
        self.makeStepViewsCircular()
    }
    
    private func makeStepViewsCircular() {
        for stepView in self.stepViewsCollection {
            stepView.layer.cornerRadius = 30/2
            stepView.layer.borderWidth = 2
            stepView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        }
        for stepView in self.stepInnerCircleCollection {
            stepView.layer.cornerRadius = 22/2
        }
    }
    
    func setCurrentStep(to step: OnboardingStep) {
        self.hideAllInnerViews()
        var innerCircleViewToShow: UIView!
        switch step {
        case .createAccount:
            innerCircleViewToShow = self.innerViewCreateAccount
        case .chooseContacts:
            innerCircleViewToShow = self.innerViewChooseContacts
        case .setPriorityLevels:
            innerCircleViewToShow = self.innerViewPriorityLevels
        case .addTags:
            innerCircleViewToShow = self.innerViewAddTags
        }
        innerCircleViewToShow.isHidden = false
    }
    
    private func hideAllInnerViews() {
        self.innerViewCreateAccount.isHidden = true
        self.innerViewChooseContacts.isHidden = true
        self.innerViewPriorityLevels.isHidden = true
        self.innerViewAddTags.isHidden = true
    }
    
    func setProgressCompletion() {
        self.hideAllInnerViews()
        for stepView in self.stepViewsCollection {
            stepView.backgroundColor = self.innerViewChooseContacts.backgroundColor
        }
    }
}
