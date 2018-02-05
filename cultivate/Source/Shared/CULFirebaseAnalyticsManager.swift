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
            case name = "Name"
            case email = "Email"
            case iOSVersion = "iOSVersion"
            case deviceModel = "DeviceModel"
            case accountCreationDate = "AccountCreationDate"
            case isOnboardingCompleted = "OnboardingCompleted"
            case onboardingCompletionDate = "OnboardingDate"
            case lastUserLogin = "LastLoginDate"
            case totalNumberOfCultivateContacts = "TotalCultivateContacts"
        }
        enum ContentTypes: String {
            case followup = "Followup"
        }
        enum Identifiers: String {
            case followup = "Followup"
        }
        enum Actions: String {
            case submit = "Submit"
            case submitWithEmptyNote = "NoNote"
            case submitWithManualDate = "ManualDate"
            case deferDate = "DeferDate"
        }
    }
    
    static let shared = CULFirebaseAnalyticsManager()
    
    func logUserSelection(with id: String, on item: String) {
        self.log(id: id, itemName: item, contentType: "USER_TAP")
    }
    
    func log(id: String, itemName: String, contentType: String, eventType: String = AnalyticsEventSelectContent) {
        Analytics.logEvent(eventType, parameters: [
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
