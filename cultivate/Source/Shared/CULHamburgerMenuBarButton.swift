//
//  CULHamburgerMenuBarButton.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class CULHamburgerMenuBarButton: UIBarButtonItem {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.image = #imageLiteral(resourceName: "ic_menu")
        self.title = ""
    }
}
