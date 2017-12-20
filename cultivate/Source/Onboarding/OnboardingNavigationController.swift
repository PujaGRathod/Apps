//
//  OnboardingNavigationController.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class OnboardingNavigationController: UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
}

extension OnboardingNavigationController: UINavigationBarDelegate {

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
            if viewcontroller.shouldPopViewController() == false {
                return false
            }
        } else if let viewcontroller: AddTagsVC = self.viewControllers.last as? AddTagsVC,
            viewcontroller.isKind(of: AddTagsVC.classForCoder()) == true {
            print("AddTagsVC")
            if viewcontroller.shouldPopViewController() == false {
                return false
            }
        }
        // Pop the view controller
        _ = self.popViewController(animated: true)
        return true
    }
}
