//
//  UIBarButtonItem.swift
//  cultivate
//
//  Created by Akshit Zaveri on 22/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    var frame: CGRect? {
        guard let view = self.view else {
            return nil
        }
        return view.frame
    }
    
    var view: UIView? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view
    }
}
