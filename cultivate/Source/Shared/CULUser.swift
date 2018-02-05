//
//  CULUser.swift
//  cultivate
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase

class CULUser {
    
    var name: String
    var email: String
    let id: String
    var isOnBoardingComplete: Bool = false
    
    func getRawData() -> [String:Any] {
        let rawData: [String:Any] = [
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "isOnBoardingComplete": self.isOnBoardingComplete,
            ]
        return rawData
    }
    
    
    init(withName: String, email: String, id: String) {
        self.id = id
        self.email = email
        self.name = withName
    }
    
    init?(with data: [String: Any]) {
        if let uid = data["id"] as? String {
            self.id = uid
            self.email = (data["email"] as? String) ?? ""
            self.name = (data["name"] as? String) ?? ""
            self.isOnBoardingComplete = (data["isOnBoardingComplete"] as? Bool) ?? false
            
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
