//
//  ContactsWorker.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Contacts

typealias ContactsHandler = (_ orderedContacts : [String: [CULContact]], _ sortedContactKeys: [String], _ error : NSError?) -> Void

class ContactsWorker {
    
    private var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    private var sortedContactKeys = [String]()
    private var contactsStore: CNContactStore?
    private var viewcontroller: UIViewController!
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        self.getContacts( {(contacts, sortedKeys, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
//                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func getContacts(_ completion:  @escaping ContactsHandler) {
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
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            var contactsArray = [CNContact]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
            contactFetchRequest.sortOrder = CNContactSortOrder.userDefault
            do {
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    contactsArray.append(contact)
                    var key: String = "#"

                    //If ordering has to be happening via family name change it here.
                    var firstLetter = contact.givenName[0..<1]
                    switch contactFetchRequest.sortOrder {
                    case .givenName:
                        firstLetter = contact.givenName[0..<1]
                    case .familyName, .none:
                        fallthrough
                    default:
                        firstLetter = contact.familyName[0..<1]
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
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    class func createCULContact(from cnContact: CNContact) -> CULContact {
        let contact: CULContact = CULContact()
        contact.identifier = cnContact.identifier
        contact.first_name = cnContact.givenName
        contact.last_name = cnContact.familyName
        return contact
    }
}
