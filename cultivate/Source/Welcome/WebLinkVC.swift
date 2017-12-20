//
//  WebLinkVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

class WebLinkVC: UIViewController {
    
    var link: String?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let link: String = self.link {
            if let url: URL = URL.init(string: link) {
                let request: URLRequest = URLRequest(url: url)
                self.webView.loadRequest(request)
            } else {
                // Dismiss
            }
        } else {
            // Dismiss
        }
    }
}
