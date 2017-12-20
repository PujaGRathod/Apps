//
//  StringExtension.swift
//  cultivate
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
        } catch {
            return false
        }
    }
}
