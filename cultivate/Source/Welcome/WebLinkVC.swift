//
//  WebLinkVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

enum WebLinkOptions {
    case privacyPolicy
    case termsOfService
    
    var values: (link: URL, title: String) {
        switch self {
        case .privacyPolicy:
            let url: URL? = URL(string: "https://termsfeed.com/privacy-policy/941cb5baa95cd444a6d3313394c4a025")
            return (url!, "Privacy Policy")
        case .termsOfService:
            let url: URL? = URL(string: "https://termsfeed.com/terms-conditions/d278e656beb4d3ad90a26d537d4fcfb0")
            return (url!, "Terms of Service")
        }
    }
}

class WebLinkVC: UIViewController {
    
    var webLinkOption: WebLinkOptions?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url: URL = self.webLinkOption?.values.link {
            let request: URLRequest = URLRequest(url: url)
            self.webView.loadRequest(request)
        } else {
            // Dismiss
        }
        self.title = self.webLinkOption?.values.title
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
