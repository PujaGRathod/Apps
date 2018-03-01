//
//  ContactsWorker.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import PhoneNumberKit

typealias ContactsHandler = (_ orderedContacts : [String: [CULContact]], _ sortedContactKeys: [String], _ error : NSError?) -> Void

class ContactsWorker {
    
    //    private var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    //    private var sortedContactKeys = [String]()
    private var contactsStore: CNContactStore?
    private var viewcontroller: UIViewController!
    
    // MARK: - Contact Operations
    
    struct KeysTemp {
        var firstNameFirstLetter: String
        var lastNameFirstLetter: String
        
        init(_ firstNameFirstLetter: String, _ lastNameFirstLetter: String) {
            self.firstNameFirstLetter = firstNameFirstLetter
            self.lastNameFirstLetter = lastNameFirstLetter
        }
    }
    
    func getContacts(sortOrder: CULContact.SortOrder, _ completion:  @escaping ContactsHandler) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {  action in
                completion([:], [], error)
                self.viewcontroller.dismiss(animated: true, completion: {
                    //                    self.contactDelegate?.epContactPicker(self, didContactFetchFailed: error)
                })
            })
            alert.addAction(okAction)
            self.viewcontroller.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore?.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion([:], [], error! as NSError?)
                    })
                }
                else{
                    self.getContacts(sortOrder: sortOrder, completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
            contactFetchRequest.unifyResults = true
            switch sortOrder {
            case .firstName:
                contactFetchRequest.sortOrder = CNContactSortOrder.givenName
            case .lastName:
                contactFetchRequest.sortOrder = CNContactSortOrder.familyName
            }
            
            var sortedContactKeys = [String]()
            
            var orderedContacts = self.getCNContacts(with: contactFetchRequest)
            
            sortedContactKeys = Array(orderedContacts.keys).sorted(by: <)
            if sortedContactKeys.first == "#" {
                sortedContactKeys.removeFirst()
                sortedContactKeys.append("#")
            }
            
            var orderedCultivateContacts: [String: [CULContact]] = [:]
            
            for key in orderedContacts.keys {
                let contactsForKey: [CNContact] = orderedContacts[key] ?? []
                var cultivateContactsForkey: [CULContact] = []
                for contact in contactsForKey {
                    cultivateContactsForkey.append(ContactsWorker.createCULContact(from: contact))
                }
                orderedCultivateContacts[key] = cultivateContactsForkey
            }
            
            completion(orderedCultivateContacts, sortedContactKeys, nil)
            
        }
    }
    
    func getCNContacts(with contactFetchRequest: CNContactFetchRequest) -> [String: [CNContact]] {
        var orderedContacts = [String: [CNContact]]()
        var contactsArray = [CNContact]()
        do {
            try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                
                //Ordering contacts based on alphabets in firstname
                contactsArray.append(contact)
                var key: String = "#"
                
                if contact.givenName.count == 0, contact.familyName.count == 0 {
                    // Do not add show this contact. This contact does not have any name
                } else {
                    //  If ordering has to be happening via family name change it here.
                    var firstLetter = contact.givenName[0..<1]
                    switch contactFetchRequest.sortOrder {
                    case .givenName:
                        if contact.givenName.count == 0 {
                            firstLetter = contact.familyName[0..<1]
                        } else {
                            firstLetter = contact.givenName[0..<1]
                        }
                    case .familyName, .none, .userDefault:
                        fallthrough
                    default:
                        if contact.familyName.count == 0 {
                            firstLetter = contact.givenName[0..<1]
                        } else {
                            firstLetter = contact.familyName[0..<1]
                        }
                    }
                    if firstLetter?.containsAlphabets() == true {
                        key = firstLetter!.uppercased()
                    }
                    var contacts = [CNContact]()
                    
                    if let segregatedContact = orderedContacts[key] {
                        contacts = segregatedContact
                    }
                    contacts.append(contact)
                    orderedContacts[key] = contacts
                }
                
            })
        } catch let error as NSError {
            //Catching exception as enumerateContactsWithFetchRequest can throw errors
            print(error.localizedDescription)
        }
        return orderedContacts
    }
    
    func getSortOrder() -> CULContact.SortOrder {
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
        switch contactFetchRequest.sortOrder {
        case .familyName, .none:
            return CULContact.SortOrder.lastName
        default:
            return CULContact.SortOrder.firstName
        }
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactInstantMessageAddressesKey as CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys(),
        ]
    }
    
    class func createCULContact(from cnContact: CNContact) -> CULContact {
        var contact: CULContact = CULContact()
        contact.identifier = cnContact.identifier
        contact.first_name = cnContact.givenName
        contact.last_name = cnContact.familyName
        contact.phoneNumbers = ContactsWorker().getPhoneNumbers(from: cnContact).map({ return $0.value })
        contact.emailAddresses = ContactsWorker().getEmailAddresses(from: cnContact).map({ return $0.value })
        return contact
    }
    
    func getThumbnailImage(forContactIdentifier identifier: String) -> UIImage? {
        let cnContact = self.getCNContact(for: identifier)
        var profileImage: UIImage? = nil
        if let data = cnContact?.thumbnailImageData,
            let image = UIImage(data: data) {
            
            profileImage = image
        }
        return profileImage
    }
    
    func getPhoneNumbers(forContactIdentifier identifier: String) -> [String:String] {
        let cnContact = self.getCNContact(for: identifier)
        guard let contact = cnContact else {
            return [String:String]()
        }
        
        return self.getPhoneNumbers(from: contact)
    }
    
    private func getPhoneNumbers(from contact: CNContact) -> [String:String] {
        var phoneNumbers = [String:String]()
        for phoneNumber in contact.phoneNumbers {
            var key: String = "phone"
            if let label = phoneNumber.label, label.isEmpty == false {
                key = CNLabeledValue<NSString>.localizedString(forLabel: label)
            }
            phoneNumbers[key] = phoneNumber.value.stringValue
        }
        return phoneNumbers
    }
    
    func getEmailAddresses(forContactIdentifier identifier: String) -> [String:String] {
        let cnContact = self.getCNContact(for: identifier)
        guard let contact = cnContact else {
            return [String:String]()
        }
        
        return self.getEmailAddresses(from: contact)
    }
    
    private func getEmailAddresses(from contact: CNContact) -> [String:String] {
        var emailAddresses = [String:String]()
        for emailAddress in contact.emailAddresses {
            var key: String = "email"
            if let label = emailAddress.label, label.isEmpty == false {
                key = CNLabeledValue<NSString>.localizedString(forLabel: label)
            }
            emailAddresses[key] = emailAddress.value as String
        }
        
        return emailAddresses
    }
    
    func getCNContact(for identifier: String) -> CNContact? {
        var cnContact: CNContact?
        
        self.contactsStore = self.getContactStore()
        
        do {
            cnContact = try self.contactsStore?.unifiedContact(withIdentifier: identifier, keysToFetch: self.allowedContactKeys())
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return cnContact
    }
    
    func getContactStore() -> CNContactStore? {
        if self.contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            self.contactsStore = CNContactStore()
        }
        return self.contactsStore
    }
    
    
    
    
    // Contact matching
    func getUnlinkedContacts(from cultivateContacts: [CULContact]) -> [CULContact] {
        var unlinkedContacts = [CULContact]()
        
        func append(contact: CULContact) {
//            print("Contact does not have an attached iOS contact \(contact.name)")
            unlinkedContacts.append(contact)
        }
        
        for contact in cultivateContacts {
            if let identifier = contact.identifier {
                if self.getCNContact(for: identifier) == nil {
                    append(contact: contact)
                } else {
//                    print("Contact does have an attached iOS contact \(contact.name)")
                }
            } else {
                append(contact: contact)
            }
        }
        return unlinkedContacts
    }
    
    private func getCNContactsArray() -> [CNContact] {
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
        contactFetchRequest.unifyResults = true
        contactFetchRequest.sortOrder = CNContactSortOrder.givenName
        let orderedContacts = self.getCNContacts(with: contactFetchRequest)
        
        var allContacts = [CNContact]()
        for orderedContact in orderedContacts {
            allContacts.append(contentsOf: orderedContact.value)
        }
        return allContacts
    }
    
    func findiOSContacts(for unlinkedContacts: [CULContact]) -> [CULContact] {
        return self.findiOSContacts(for: unlinkedContacts, from: self.getCNContactsArray())
    }
    
    func findiOSContacts(for unlinkedContacts: [CULContact],
                         from alliOSContacts: [CNContact]) -> [CULContact] {
        var linkedContacts = [CULContact]()
        print("\(Date()) findiOSContacts(for: from:) START1")
        
        for unlinkedContact in unlinkedContacts {
            for contact in alliOSContacts {
                let areEqual = self.areEqual(cultivateContact: unlinkedContact, iOSContact: contact)
                if areEqual {
                    var linkedContact = unlinkedContact
                    linkedContact.identifier = contact.identifier
                    linkedContacts.append(linkedContact)
                    print("****** Found iOS contact for cultivate contact \(unlinkedContact.name)")
                    break
                }
            }
        }
        print("\(Date()) findiOSContacts(for: from:) START2")
        return linkedContacts
    }
    
    func areEqual(cultivateContact: CULContact, iOSContact: CNContact) -> Bool {
        let firstNameMatched = self.isFirstNameMatched(cultivateContact: cultivateContact, iOSContact: iOSContact)
        let middleNameMatched = self.isMiddleNameMatched(cultivateContact: cultivateContact, iOSContact: iOSContact)
        let lastNameMatched = self.isLastNameMatched(cultivateContact: cultivateContact, iOSContact: iOSContact)
        if firstNameMatched, middleNameMatched, lastNameMatched {
            return true
        }
        
        let phoneNumberMatched = self.atleastOnePhoneNumberMatchedBetween(cultivatePhoneNumbers: cultivateContact.phoneNumbers, iOSContactPhoneNumbers: iOSContact.phoneNumbers)
        if phoneNumberMatched {
            return true
        }
        
        let emailAddressMatched = self.atleastOneEmailAddressMatchedBetween(cultivateEmailAddresses: cultivateContact.emailAddresses, iOSContactEmailAddresses: iOSContact.emailAddresses)
        if emailAddressMatched {
            return true
        }
        
        return false
    }
    
    func isFirstNameMatched(cultivateContact: CULContact, iOSContact: CNContact) -> Bool {
        let cultivateFirstName = cultivateContact.first_name?.lowercased()
        let iOSContactFirstName = iOSContact.givenName.lowercased()
        if cultivateFirstName == iOSContactFirstName {
            return true
        }
        
        return false
    }
    
    func isMiddleNameMatched(cultivateContact: CULContact, iOSContact: CNContact) -> Bool {
        guard let cultivateMiddleName = cultivateContact.middle_name?.lowercased() else {
            return true
        }
        let iOSContactMiddleName = iOSContact.middleName.lowercased()
        if iOSContactMiddleName.count == 0 {
            return true
        }
        if cultivateMiddleName == iOSContactMiddleName {
            return true
        }
        
        return false
    }
    
    func isLastNameMatched(cultivateContact: CULContact, iOSContact: CNContact) -> Bool {
        let cultivateLastName = cultivateContact.last_name?.lowercased()
        let iOSContactLastName = iOSContact.familyName.lowercased()
        if cultivateLastName == iOSContactLastName {
            return true
        }
        
        return false
    }
    
    static let phoneNumberKit = PhoneNumberKit()
    func atleastOnePhoneNumberMatchedBetween(cultivatePhoneNumbers: [String], iOSContactPhoneNumbers: [CNLabeledValue<CNPhoneNumber>]) -> Bool {
        
        let parsedNumbers1 = ContactsWorker.phoneNumberKit.parse(cultivatePhoneNumbers)
        let parsedNumbers2 = ContactsWorker.phoneNumberKit.parse(iOSContactPhoneNumbers.map({ $0.value.stringValue }))
//
//        for phoneNumber1 in parsedNumbers1 {
//            for phoneNumber2 in parsedNumbers2 {
//                if phoneNumber1 == phoneNumber2 {
//                    return true
//                }
//            }
//        }
        
        return false
    }
    
    func atleastOneEmailAddressMatchedBetween(cultivateEmailAddresses: [String], iOSContactEmailAddresses: [CNLabeledValue<NSString>]) -> Bool {
        
        for email in cultivateEmailAddresses {
            let fiteredEmail = iOSContactEmailAddresses.filter({ $0.value.lowercased == email.lowercased() })
            if fiteredEmail.count > 0 {
                return true
            }
        }
        return false
    }
    
    func updateCultivateContacts() {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            var allUpdatedContacts = [CULContact]()
            CULFirebaseGateway.shared.getContacts(for: user, { (cultivateContacts) in
                for cultivateContact in cultivateContacts {
                    if let identifier = cultivateContact.identifier,
                        let cnContact = self.getCNContact(for: identifier)  {
                        
                        let updatedContact = self.copy(from: cnContact, to: cultivateContact)
                        allUpdatedContacts.append(updatedContact)
                    }
                }
                
                CULFirebaseGateway.shared.update(contacts: allUpdatedContacts, for: user, completion: { (error) in
                    print("All contacts updated with latest values")
                })
            })
        }
    }
    
    private func copy(from iOSContact: CNContact, to cultivateContact: CULContact) -> CULContact {
        var contact = ContactsWorker.createCULContact(from: iOSContact)
        contact.db_Identifier = cultivateContact.db_Identifier
        return contact
    }
    
    
    //    func addTestData() {
    //        let mutableContact = self.getCNContact(for: "410FE041-5C4E-48DA-B4DE-04C15EA3DBAC")?.mutableCopy() as? CNMutableContact
    //
    //        let value = CNInstantMessageAddress(username: "Id", service: "Cultivate")
    //        let label = CNLabeledValue(label: "Label", value: value)
    //        mutableContact?.instantMessageAddresses.append(label)
    //
    //        let store = self.getContactStore()
    //
    //        let saveRequest = CNSaveRequest()
    //        saveRequest.update(mutableContact!)
    //
    //        do {
    //            try store?.execute(saveRequest)
    //        } catch {
    //            print(error)
    //        }
    //    }
}
