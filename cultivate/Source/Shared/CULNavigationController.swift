//
//  CULNavigationController.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class CULNavigationController: UINavigationController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
}

extension CULNavigationController: UINavigationBarDelegate {
    
//    func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
//        return true
//    }
//
//    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
//
//    }
//
//    func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
//
//    }
//
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let viewcontroller: SetFollowupFrequenciesVC = self.viewControllers.last as? SetFollowupFrequenciesVC,
            viewcontroller.isKind(of: SetFollowupFrequenciesVC.classForCoder()) == true {
            print("SetFollowupFrequenciesVC")
            return viewcontroller.shouldPopViewController()
        } else if let viewcontroller: AddTagsVC = self.viewControllers.last as? AddTagsVC,
            viewcontroller.isKind(of: AddTagsVC.classForCoder()) == true {
            print("AddTagsVC")
            return viewcontroller.shouldPopViewController()
        } else if let viewcontroller: OnboardingCompletedVC = self.viewControllers.last as? OnboardingCompletedVC,
            viewcontroller.isKind(of: OnboardingCompletedVC.classForCoder()) == true {
            print("OnboardingCompletedVC")
            return viewcontroller.shouldPopViewController()
        }
        // Pop the view controller
        _ = self.popViewController(animated: true)
        return true
    }
}
