//
//  CULUser.swift
//  cultivate
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase

struct NotificationSettings {
    enum Frequency: String {
        case daily
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
    var time: String = "09:00"
    var frequency: Frequency = .monday
}

class CULUser {
    
    var name: String
    var email: String
    let id: String
    var isOnBoardingComplete = false
    var isDashboardHintsShown = false
    var isFollowupHintsShown = false
    var notificationSettings: NotificationSettings?
    
    func getRawData() -> [String:Any] {
        var rawData: [String:Any] = [
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "isOnBoardingComplete": self.isOnBoardingComplete,
            "isDashboardHintsShown": self.isDashboardHintsShown,
            "isFollowupHintsShown": self.isFollowupHintsShown,
            ]
        if let ns = self.notificationSettings {
            rawData["notificationSettings"] = "\(ns.frequency),\(ns.time)"
        }
        return rawData
    }
    
    
    init(withName: String, email: String, id: String) {
        self.id = id
        self.email = email
        self.name = withName
        
        if self.notificationSettings == nil {
            var ns = NotificationSettings()
            ns.frequency = .daily
            ns.time = "09:00"
            self.notificationSettings = ns
        }
    }
    
    init?(with data: [String: Any]) {
        if let uid = data["id"] as? String {
            self.id = uid
            self.email = (data["email"] as? String) ?? ""
            self.name = (data["name"] as? String) ?? ""
            self.isOnBoardingComplete = (data["isOnBoardingComplete"] as? Bool) ?? false
            self.isDashboardHintsShown = (data["isDashboardHintsShown"] as? Bool) ?? false
            self.isFollowupHintsShown = (data["isFollowupHintsShown"] as? Bool) ?? false
            
            if let settings = data["notificationSettings"] as? String {
                let list = settings.components(separatedBy: ",")
                if list.count == 2,
                    let frequency = list.first,
                    let time = list.last {
                    var ns = NotificationSettings()
                    ns.frequency = NotificationSettings.Frequency.init(rawValue: frequency) ?? .monday
                    ns.time = time
                    self.notificationSettings = ns
                }
            }
            
        } else {
            return nil
        }
        
    }
    
    class func checkIfUserExist(with id: String, completion: @escaping (CULUser?, Bool) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(id)
        userRef.getDocument { (user, error) in
            if user?.exists == true,
                let data = user?.data() {
                completion(CULUser.init(with: data), true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    func save() {
        let userRef = Firestore.firestore().collection("users").document(self.id)
        print("saving user: \(self.getRawData())")
        userRef.setData(self.getRawData())
    }
    
}
