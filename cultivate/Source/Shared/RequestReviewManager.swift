//
//  RequestReviewManager.swift
//  cultivate
//
//  Created by Akshit Zaveri on 22/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation
import StoreKit

class RequestReviewManager {
    
    private var KeyAppInstallDate = "KEY_APP_INSTALL_DATE"
    private var userDefaults = UserDefaults.standard
    
    func askForReview() {
        if self.shouldAskForReview() {
            SKStoreReviewController.requestReview()
        }
    }
    
    func shouldAskForReview() -> Bool {
        if let string = self.userDefaults.string(forKey: KeyAppInstallDate) {
            guard let date = self.date(from: string) else {
                // Error parsing the date
                return false
            }
            if self.daysSinceInstallation(date: date) > 7 {
                return true
            }
        } else {
            // App is being installed for the first time
            self.userDefaults.set(self.string(from: Date()), forKey: KeyAppInstallDate)
            self.userDefaults.synchronize()
        }
        return false
    }
    
    private func date(from string: String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .full
        dateformatter.timeStyle = .full
        return dateformatter.date(from: string)
    }
    
    private func string(from date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .full
        dateformatter.timeStyle = .full
        return dateformatter.string(from: date)
    }
    
    private func daysSinceInstallation(date: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps = calendar.dateComponents([.day], from: date, to: Date())
        let days = comps.day ?? 0
        print("Days since installation: \(days)")
        return days
    }
}
