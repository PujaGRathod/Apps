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
    
    func localPersistence(_ enable: Bool) {
        // Enabling data persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = enable
        Firestore.firestore().settings = settings
    }
    
    func deleteUnusedTags() {
        guard let user = CULFirebaseGateway.shared.loggedInUser else {
            return
        }
        
        self.getUnusedTags { (tags) in
            let store = Firestore.firestore()
            let batch = store.batch()
            for tag in tags {
                if let id = tag.identifier {
                    let ref = store.collection("users").document(user.id).collection("tags").document(id)
                    batch.deleteDocument(ref)
                }
            }
            batch.commit { (error) in
                // Unused tags feleted
            }
        }
    }
    
    private func getUnusedTags(_ completion: @escaping (([CULTag])->Void)) {
        let group = DispatchGroup()
        
        var allContacts = [CULContact]()
        var allTags = [CULTag]()
        var unusedTags = [CULTag]()
        
        if let user = CULFirebaseGateway.shared.loggedInUser {
            group.enter()
            group.enter()
            self.getTags(for: user, { (tags) in
                allTags = tags
                group.leave()
            })
            
            self.getContacts(for: user, { (contacts) in
                allContacts = contacts
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue(label: "backgroundQueue")) {
            for tag in allTags {
                let contactsWithTag = allContacts.filter({ $0.tag?.identifier == tag.identifier })
                if contactsWithTag.count == 0 {
                    // Unused tag
                    unusedTags.append(tag)
                }
            }
            completion(unusedTags)
        }
    }
    
    func setOnboardingCompleted(for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let ref = store.collection("users").document(user.id)
        let data: [String:Any] = [
            "isOnBoardingComplete" : true
        ]
        ref.updateData(data) { (error) in
            completion(error)
        }
    }
    
    func setDashboardHintsShown(for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let ref = store.collection("users").document(user.id)
        let data: [String:Any] = [
            "isDashboardHintsShown" : true
        ]
        ref.updateData(data) { (error) in
            completion(error)
        }
    }
    
    func setFollowupHintsShown(for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let ref = store.collection("users").document(user.id)
        let data: [String:Any] = [
            "isFollowupHintsShown" : true
        ]
        ref.updateData(data) { (error) in
            completion(error)
        }
    }
    
    func addNew(contacts: [CULContact], for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let batch: WriteBatch = store.batch()
        for var contact in contacts {
            let ref = store.collection("users").document(user.id).collection("contacts").document()
            contact.db_Identifier = ref.documentID
            let data: [String:Any] = self.convertContactToRawData(contact)
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
            if let id = contact.db_Identifier {
                let ref = store.collection("users").document(user.id).collection("contacts").document(id)
                batch.updateData(data, forDocument: ref)
            }
        }
        batch.commit { (error) in
            completion(error)
        }
    }
    
    func delete(contacts: [CULContact], for user: CULUser, _ completion: @escaping ((Error?)->Void)) {
        let store = Firestore.firestore()
        let batch = store.batch()
        for contact in contacts {
            if let id = contact.db_Identifier {
                let ref = store.collection("users").document(user.id).collection("contacts").document(id)
                batch.deleteDocument(ref)
            }
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
        
        if contact.followupFrequency == .none {
//            assertionFailure("Frequency can't be empty")
        }
        
        if let tagId = contact.tag?.identifier {
            raw["tag"] = tagId
        } else {
            raw["tag"] = ""
        }
        
        if let date = contact.followupDate {
            raw["followupDate"] = String(describing: date.timeIntervalSinceReferenceDate)
        }
        
        raw["notes"] = contact.notes ?? ""
        
        raw["phoneNumbers"] = contact.phoneNumbers
        raw["emailAddresses"] = contact.emailAddresses
        
        return raw
    }
    
    func getTags(for user: CULUser, _ completion:@escaping (([CULTag])->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("tags")
        //        var listener: ListenerRegistration?
        //        listener = ref.addSnapshotListener({ (snapshot, error) in
        ref.getDocuments { (snapshot, error) in
            
            //            if snapshot?.metadata.isFromCache == false {
            //            listener?.remove()
            print("Listener removed for getTags ********** ")
            //            }
            
            var tags: [CULTag] = []
            for document in snapshot?.documents ?? [] {
                var tag = self.tag(from: document.data())
                tag.identifier = document.documentID
                tags.append(tag)
            }
            tags.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
            completion(tags)
            
            //        })
        }
    }
    
    func getTag(with id: String, for user: CULUser, _ completion:@escaping ((CULTag?)->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("tags").document(id)
        //        var listener: ListenerRegistration?
        //        listener = ref.addSnapshotListener({ (snapshot, error) in
        ref.getDocument { (snapshot, error) in
            //            listener?.remove()
            print("Listener removed for getTag ********** ")
            if let data = snapshot?.data(),
                let dbId = snapshot?.documentID {
                
                var tag = self.tag(from: data)
                tag.identifier = dbId
                completion(tag)
            } else {
                completion(nil)
            }
            //        })
        }
    }
    
    private func tag(from raw: [String:Any]) -> CULTag {
        var tag = CULTag()
        tag.name = raw["name"] as? String
        return tag
    }
    
    private func convertTagToRawData(_ tag: CULTag) -> [String:Any] {
        var rawData = [String:Any]()
        rawData["name"] = tag.name
        return rawData
    }
    
    func update(tag: CULTag, for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store: Firestore = Firestore.firestore()
        let data = self.convertTagToRawData(tag)
        if let id = tag.identifier {
            let ref = store.collection("users").document(user.id).collection("tags").document(id)
            ref.updateData(data, completion: { (error) in
                completion(error)
            })
        }
    }
    
    // Get all contacts for the current user
    func getContacts(for user: CULUser, _ completion:@escaping (([CULContact])->Void)) {
        print("\(Date()) Called getContacts ********** ")
        
        let ref = Firestore.firestore().collection("users").document(user.id).collection("contacts")
        //        var listener: ListenerRegistration?
        //        listener = ref.addSnapshotListener({ (snapshot, error) in
        ref.getDocuments { (snapshot, error) in
            
            //            if snapshot?.metadata.isFromCache == false {
            //            listener?.remove()
            print("\(Date()) Ended getContacts ********** ")
            //            }
            
            var contacts: [CULContact] = []
            for document in snapshot?.documents ?? [] {
                if var contact = self.contact(from: document.data()) {
                    contact.db_Identifier = document.documentID
                    contacts.append(contact)
                }
            }
            self.getTags(for: user, { (tags) in
                contacts = self.map(tags: tags, with: contacts)
                completion(contacts)
            })
            //        })
        }
    }
    
    func getContact(with id: String, for user: CULUser, _ completion:@escaping ((CULContact?)->Void)) {
        let ref = Firestore.firestore().collection("users").document(user.id).collection("contacts").document(id)
        //        var listener: ListenerRegistration?
        //        listener = ref.addSnapshotListener({ (snapshot, error) in
        ref.getDocument { (snapshot, error) in
            //            listener?.remove()
            print("Listener removed for getContact ********** ")
            if let data = snapshot?.data(),
                let dbId = snapshot?.documentID {
                if var contact = self.contact(from: data) {
                    contact.db_Identifier = dbId
                    if let tagId = contact.tag?.identifier, tagId.count > 0 {
                        self.getTag(with: tagId, for: user, { (tag) in
                            contact.tag = tag
                            completion(contact)
                        })
                    } else {
                        completion(contact)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            //        })
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
        if contact.followupFrequency == .none {
//            assertionFailure("Frequency can't be empty")
        }
        
        var tag = CULTag()
        tag.identifier = raw["tag"] as? String
        contact.tag = tag
        
        if let string = raw["followupDate"] as? String {
            if let timeInterval = Double(string) {
                let dateTemp = Date(timeIntervalSinceReferenceDate: timeInterval)
                contact.followupDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateTemp)
            }
        }
        
        contact.notes = raw["notes"] as? String
        
        contact.phoneNumbers = raw["phoneNumbers"] as? [String] ?? []
        contact.emailAddresses = raw["emailAddresses"] as? [String] ?? []
        
        return contact
    }
    
    private func map(tags: [CULTag], with contacts: [CULContact]) -> [CULContact] {
        print("\(Date()) Mapping started ***********")
        
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
        
        print("\(Date()) Mapping end ***********")
        
        return mappedContacts
    }
    
    func addNew(followup: CULContact.Followup, for contact: CULContact, loggedInUser: CULUser, _ completion: @escaping ((Error?)->Void)) {
        let store = Firestore.firestore()
        let data = self.convertFollowupToRawData(followup)
        let keysCount = data.keys.count
        guard keysCount > 0 else {
            let error = NSError(domain: "No data to update", code: 0, userInfo: [:])
            completion(error)
            return
        }
        if let id = contact.db_Identifier{
            let ref = store.collection("users").document(loggedInUser.id).collection("contacts").document(id).collection("followups").document()
            ref.setData(data) { (error) in
                completion(error)
            }
        }
    }
    
    private func convertFollowupToRawData(_ followup: CULContact.Followup) -> [String:Any] {
        var data = [String:Any]()
        guard let timeInterval = followup.date?.timeIntervalSinceReferenceDate else {
            return [:]
        }
        
        data["date"] = String(describing: timeInterval)
        data["notes"] = followup.notes ?? ""
        
        return data
    }
    
    func getFollowups(for contact: CULContact, loggedInUser: CULUser, _ completion: @escaping (([CULContact.Followup],Error?)->Void)) {
        let store = Firestore.firestore()
        if let id = contact.db_Identifier {
            let ref = store.collection("users").document(loggedInUser.id).collection("contacts").document(id).collection("followups")
            
            //            var listener: ListenerRegistration?
            //            listener = ref.addSnapshotListener({ (snapshot, error) in
            
            ref.getDocuments(completion: { (snapshot, error) in
                
                //                if snapshot?.metadata.isFromCache == false {
                //                listener?.remove()
                print("Listener removed for getFollowups ********** ")
                //                }
                
                //            ref.getDocuments { (snapshot, error) in
                var followups = [CULContact.Followup]()
                for document in snapshot?.documents ?? [] {
                    if let followup = self.followup(from: document.data()) {
                        followups.append(followup)
                    }
                }
                completion(followups, error)
                //            }
            })
        }
    }
    
    private func followup(from raw: [String:Any]) -> CULContact.Followup? {
        var followup = CULContact.Followup()
        
        if let string = raw["date"] as? String,
            let timeInterval = Double(string) {
            
            followup.date = Date(timeIntervalSinceReferenceDate: timeInterval)
        } else {
            return nil
        }
        
        followup.notes = raw["notes"] as? String
        
        return followup
    }
    
    func submit(feedback: String, for user: CULUser, _ completion: @escaping ((Error?)->Void)) {
        let store = Firestore.firestore()
        let ref = store.collection("feedbacks").document()
        ref.setData([ "notes": feedback, "user": user.id ]) { (error) in
            completion(error)
        }
    }
    
    func update(notificationSettings: NotificationSettings, for user: CULUser, completion: @escaping ((Error?)->Void)) {
        let store = Firestore.firestore()
        let ref = store.collection("users").document(user.id)
        let data = [ "notificationSettings": "\(notificationSettings.frequency),\(notificationSettings.time)" ]
        ref.updateData(data) { (error) in
            completion(error)
        }
    }
}
