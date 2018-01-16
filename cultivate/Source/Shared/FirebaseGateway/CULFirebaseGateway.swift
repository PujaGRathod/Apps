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
    
    func getTags(for user: CULUser, _ completion:@escaping (([CULTag])->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("tags")
        ref.getDocuments { (snapshots, error) in
            var tags: [CULTag] = []
            for document in snapshots?.documents ?? [] {
                var tag = self.tag(from: document.data())
                tag.identifier = document.documentID
                tags.append(tag)
            }
            completion(tags)
        }
    }
    
    private func tag(from raw: [String:Any]) -> CULTag {
        var tag = CULTag()
        tag.name = raw["name"] as? String
        return tag
    }
    
    
    // Get all contacts for the current user
    func getContacts(for user: CULUser, _ completion:@escaping (([CULContact])->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("contacts")
        ref.getDocuments { (snapshots, error) in
            var contacts: [CULContact] = []
            for document in snapshots?.documents ?? [] {
                if var contact = self.contact(from: document.data()) {
                    contact.db_Identifier = document.documentID
                    contacts.append(contact)
                }
            }
            self.getTags(for: user, { (tags) in
                contacts = self.map(tags: tags, with: contacts)
                completion(contacts)
            })
        }
    }
    
    private func contact(from raw: [String:Any]) -> CULContact? {
        var contact = CULContact()
        
        guard let identifier = raw["identifier"] as? String else {
            return nil
        }
        
        contact.identifier = identifier
        contact.first_name = raw["first_name"] as? String
        contact.last_name = raw["last_name"] as? String
        if let freq = raw["followupFrequency"] as? String {
            contact.followupFrequency = CULFollowupFrequency(rawValue: freq) ?? .none
        }
        
        var tag = CULTag()
        tag.identifier = raw["tag"] as? String
        contact.tag = tag
        
        if let string = raw["followupDate"] as? String {
            if let timeInterval = Double(string) {
                contact.followupDate = Date(timeIntervalSinceReferenceDate: timeInterval)
            }
        }
        
        return contact
    }
    
    private func map(tags: [CULTag], with contacts: [CULContact]) -> [CULContact] {
        var mappedContacts = [CULContact]()
        for contact in contacts {
            var contactTag: CULTag?
            for tag in tags {
                if tag.identifier == contact.tag?.identifier {
                    contactTag = tag
                    break
                }
            }
            var mappedContact = contact
            mappedContact.tag = contactTag
            mappedContacts.append(mappedContact)
        }
        return mappedContacts
    }
}
