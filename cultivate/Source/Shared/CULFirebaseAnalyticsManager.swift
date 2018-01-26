//
//  CULFirebaseAnalyticsManager.swift
//  cultivate
//
//  Created by Akshit Zaveri on 26/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation
import Firebase

class CULFirebaseAnalyticsManager {
    
    enum Keys {
        enum UserProperties: String {
            case name = "NAME"
            case email = "EMAIL"
            case iOSVersion = "iOS_VERSION"
            case deviceModel = "DEVICE_MODEL"
            case accountCreationDate = "ACCOUNT_CREATION_DATE"
            case isOnboardingCompleted = "ONBOARDING_COMPLETED"
            case onboardingCompletionDate = "ONBOARDING_DATE"
            case lastUserLogin = "LAST_LOGIN_DATE"
            case totalNumberOfCultivateContacts = "TOTAL_CULTIVATE_CONTACTS"
        }
        enum ContentTypes: String {
            case followup = "FOLLOWUP"
        }
        enum Identifiers: String {
            case followup = "FOLLOWUP"
        }
    }
    
    static let shared = CULFirebaseAnalyticsManager()
    
    func logUserTap(with id: String, on item: String) {
        self.log(id: id, itemName: item, contentType: "USER_TAP")
    }
    
    func log(id: String, itemName: String, contentType: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(id)" as NSObject,
            AnalyticsParameterItemName: itemName as NSObject,
            AnalyticsParameterContentType: contentType as NSObject
            ])
    }
    
    func set(property: Keys.UserProperties, value: Date) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let string = dateformatter.string(from: value)
        self.set(property: property, value: string)
    }
    
    func set(property: Keys.UserProperties, value: Int) {
        self.set(property: property, value: "\(value)")
    }
    
    func set(property: Keys.UserProperties, value: String) {
        Analytics.setUserProperty(value, forName: property.rawValue)
    }
}
