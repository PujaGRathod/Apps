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

typealias ContactsHandler = (_ orderedContacts : [String: [CULContact]], _ sortedContactKeys: [String], _ error : NSError?) -> Void

class ContactsWorker {
    
    private var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    private var sortedContactKeys = [String]()
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
            var contactsArray = [CNContact]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
            contactFetchRequest.unifyResults = true
            switch sortOrder {
            case .firstName:
                contactFetchRequest.sortOrder = CNContactSortOrder.givenName
            case .lastName:
                contactFetchRequest.sortOrder = CNContactSortOrder.familyName
            }
            do {
                
                self.sortedContactKeys = []
                self.orderedContacts = [:]
                
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
                        
                        if let segregatedContact = self.orderedContacts[key] {
                            contacts = segregatedContact
                        }
                        contacts.append(contact)
                        self.orderedContacts[key] = contacts
                    }
                    
                })
                
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    self.sortedContactKeys.append("#")
                }
                
                var orderedCultivateContacts: [String: [CULContact]] = [:]
                
                for key in self.orderedContacts.keys {
                    let contactsForKey: [CNContact] = self.orderedContacts[key] ?? []
                    var cultivateContactsForkey: [CULContact] = []
                    for contact in contactsForKey {
                        cultivateContactsForkey.append(ContactsWorker.createCULContact(from: contact))
                    }
                    orderedCultivateContacts[key] = cultivateContactsForkey
                }
                
                completion(orderedCultivateContacts, self.sortedContactKeys, nil)
            }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
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
        //        if let components = cnContact.birthday {
        //            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        //            contact.birthday = calendar.date(from: components)
        //        }
        
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
        var phoneNumbers = [String:String]()
        
        let cnContact = self.getCNContact(for: identifier)
        guard let contact = cnContact else {
            return phoneNumbers
        }
        
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
        var emailAddresses = [String:String]()
        
        let cnContact = self.getCNContact(for: identifier)
        guard let contact = cnContact else {
            return emailAddresses
        }
        
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
