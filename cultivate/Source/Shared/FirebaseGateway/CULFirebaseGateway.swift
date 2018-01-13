//
//  CULFirebaseGateway.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation
import Firebase

class CULFirebaseGateway {
    
    static let shared = CULFirebaseGateway()
    var loggedInUser: CULUser?
    
//    func getLoggedInUser(_ completion: @escaping ((CULUser?)->Void)) {
//        if let currentUser = Auth.auth().currentUser {
//            CULUser.checkIfUserExist(with: currentUser.uid, completion: { (loggedInUser, success) in
//                completion(loggedInUser)
//            })
//        } else {
//            completion(nil)
//        }
//    }
    
    func setOnboardingCompleted(for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let ref = store.collection("users").document(user.id)
        ref.updateData([ "isOnBoardingComplete" : true ]) { (error) in
            completion(error)
        }
    }
    
    func addNew(contacts: [CULContact], for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let batch: WriteBatch = store.batch()
        for contact in contacts {
            let data: [String:Any] = self.convertContactToRawData(contact)
            let ref = store.collection("users").document(user.id).collection("contacts").document()
            batch.setData(data, forDocument: ref)
        }
        batch.commit { (error) in
            completion(error)
        }
    }
    
    func update(contacts: [CULContact], for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let batch: WriteBatch = store.batch()
        for contact in contacts {
            let data: [String:Any] = self.convertContactToRawData(contact)
            let ref = store.collection("users").document(user.id).collection("contacts").document(contact.db_Identifier)
            batch.updateData(data, forDocument: ref)
        }
        batch.commit { (error) in
            completion(error)
        }
    }
    
    private func convertContactToRawData(_ contact: CULContact) -> [String:Any] {
        var raw: [String:Any] = [:]
        
        raw["identifier"] = contact.identifier
        
        if let first_name = contact.first_name {
            raw["first_name"] = first_name
        }
        
        if let last_name = contact.last_name {
            raw["last_name"] = last_name
        }
        
        raw["followupFrequency"] = contact.followupFrequency.rawValue
        
        if let tagId = contact.tag?.identifier {
            raw["tag"] = tagId
        }
        
        if let date = contact.followupDate {
            raw["followupDate"] = String(describing: date.timeIntervalSinceReferenceDate)
        }
        
        return raw
    }
    
    
    // Get all contacts for the current user
    func getContacts(for user: CULUser, _ completion:@escaping (([CULContact])->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("contacts")
        ref.getDocuments { (snapshots, error) in
            var contacts: [CULContact] = []
            for document in snapshots?.documents ?? [] {
                if let contact = self.contact(from: document.data()) {
                    contact.db_Identifier = document.documentID
                    contacts.append(contact)
                }
            }
            completion(contacts)
        }
    }
    
    private func contact(from raw: [String:Any]) -> CULContact? {
        let contact = CULContact()
        
        guard let identifier = raw["identifier"] as? String else {
            return nil
        }
        
        contact.identifier = identifier
        contact.first_name = raw["first_name"] as? String
        contact.last_name = raw["last_name"] as? String
        if let freq = raw["followupFrequency"] as? String {
            contact.followupFrequency = CULFollowupFrequency(rawValue: freq) ?? .none
        }
        contact.tag?.identifier = raw["tag"] as? String
        
        if let string = raw["followupDate"] as? String {
            if let timeInterval = Double(string) {
                contact.followupDate = Date(timeIntervalSinceReferenceDate: timeInterval)
            }
        }
        
        return contact
    }
}
