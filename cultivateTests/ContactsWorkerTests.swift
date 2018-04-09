////
////  ContactsWorkerTests.swift
////  cultivateTests
////
////  Created by Akshit Zaveri on 13/02/18.
////  Copyright © 2018 Akshit Zaveri. All rights reserved.
////
//
//import XCTest
//@testable import cultivate
//import Contacts
//
//class ContactsWorkerTests: XCTestCase {
//    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testLinkContactsSuccess() {
//        let mockCULContact = self.mockCULContact(firstName: "Akshit",
//                                                 middleName: "D",
//                                                 lastName: "Zaveri",
//                                                 phoneNumbers: [ "9426390589", "8160696917" ],
//                                                 emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact = self.mockCNContact(identifier: "someId",
//                                               firstName: "Akshit",
//                                               middleName: "D",
//                                               lastName: "Zaveri",
//                                               phoneNumbers: [ "9426390589" ],
//                                               emailAddresses: [])
//        
//        let linkedContacts = ContactsWorker().findiOSContacts(for: [ mockCULContact ], from: [ mockCNContact ])
//        XCTAssertEqual(linkedContacts.first!.identifier, mockCNContact.identifier)
//    }
//    
//    func testLinkContactsFailure() {
//        let mockCULContact = self.mockCULContact(firstName: "Akshit",
//                                                 middleName: "D",
//                                                 lastName: "Zaveri",
//                                                 phoneNumbers: [ "9426390589", "8160696917" ],
//                                                 emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact = self.mockCNContact(identifier: "someId",
//                                               firstName: "Akst",
//                                               middleName: "D",
//                                               lastName: "Zaveri",
//                                               phoneNumbers: [ "94390589" ],
//                                               emailAddresses: [ ])
//        
//        let linkedContacts = ContactsWorker().findiOSContacts(for: [ mockCULContact ], from: [ mockCNContact ])
//        XCTAssertEqual(linkedContacts.count, 0)
//    }
//    
//    func testContactMatching() {
//        let mockCULContact = self.mockCULContact(firstName: "Akshit",
//                                                 middleName: "D",
//                                                 lastName: "Zaveri",
//                                                 phoneNumbers: [ "9426390589", "8160696917" ],
//                                                 emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact = self.mockCNContact(firstName: "Akshit",
//                                               middleName: "D",
//                                               lastName: "Zaveri",
//                                               phoneNumbers: [ "9426390589" ],
//                                               emailAddresses: [])
//        let areEqual = ContactsWorker().areEqual(cultivateContact: mockCULContact, iOSContact: mockCNContact)
//        XCTAssertTrue(areEqual)
//        
//        
//        let mockCULContact1 = self.mockCULContact(firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ "9426390589", "8160696917" ],
//                                                  emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit",
//                                                lastName: "Zaveri",
//                                                phoneNumbers: [ "9426390589" ],
//                                                emailAddresses: [])
//        let areEqual1 = ContactsWorker().areEqual(cultivateContact: mockCULContact1, iOSContact: mockCNContact1)
//        XCTAssertTrue(areEqual1)
//        
//        
//        let mockCULContact2 = self.mockCULContact(firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ "9426390589", "8160696917" ],
//                                                  emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact2 = self.mockCNContact(firstName: "Akki",
//                                                lastName: "Z",
//                                                phoneNumbers: [ "9426390589" ],
//                                                emailAddresses: [])
//        let areEqual2 = ContactsWorker().areEqual(cultivateContact: mockCULContact2, iOSContact: mockCNContact2)
//        XCTAssertTrue(areEqual2)
//        
//        
//        let mockCULContact3 = self.mockCULContact(firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ "9426390589", "8160696917" ],
//                                                  emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact3 = self.mockCNContact(firstName: "Akki",
//                                                lastName: "Z",
//                                                phoneNumbers: [ "942639" ],
//                                                emailAddresses: [ "akshit.zaveri@gmail.com" ])
//        let areEqual3 = ContactsWorker().areEqual(cultivateContact: mockCULContact3, iOSContact: mockCNContact3)
//        XCTAssertTrue(areEqual3)
//        
//        
//        let mockCULContact4 = self.mockCULContact(firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ "9426390589", "8160696917" ],
//                                                  emailAddresses: [ "akshit.zaveri@gmail.com", "zaveri.akshit@gmail.com" ])
//        let mockCNContact4 = self.mockCNContact(firstName: "Akki",
//                                                lastName: "Z",
//                                                phoneNumbers: [ "942639" ],
//                                                emailAddresses: [ "akshitzaveri@gmail.com" ])
//        let areEqual4 = ContactsWorker().areEqual(cultivateContact: mockCULContact4, iOSContact: mockCNContact4)
//        XCTAssertFalse(areEqual4)
//    }
//    
//    func testFirstNameMatching() {
//        let mockCNContact = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["919426390589"])
//        let result = ContactsWorker().isFirstNameMatched(cultivateContact: mockCULContact, iOSContact: mockCNContact)
//        XCTAssertTrue(result)
//        
//        
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact1 = self.mockCULContact(firstName: "Zaveri", lastName: "Akshit", phoneNumbers: ["919426390589"])
//        let result1 = ContactsWorker().isFirstNameMatched(cultivateContact: mockCULContact1, iOSContact: mockCNContact1)
//        XCTAssertFalse(result1)
//        
//        
//        let mockCNContact2 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact2 = self.mockCULContact(firstName: "Akshit1", lastName: "Zaveri", phoneNumbers: ["919426390589"])
//        let result2 = ContactsWorker().isFirstNameMatched(cultivateContact: mockCULContact2, iOSContact: mockCNContact2)
//        XCTAssertFalse(result2)
//    }
//    
//    func testMiddleNameMatching() {
//        let mockCNContact = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["919426390589"])
//        let result = ContactsWorker().isMiddleNameMatched(cultivateContact: mockCULContact, iOSContact: mockCNContact)
//        XCTAssertTrue(result)
//        
//        
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact1 = self.mockCULContact(firstName: "Zaveri", lastName: "Akshit", phoneNumbers: ["919426390589"])
//        let result1 = ContactsWorker().isMiddleNameMatched(cultivateContact: mockCULContact1, iOSContact: mockCNContact1)
//        XCTAssertTrue(result1)
//        
//        
//        let mockCNContact2 = self.mockCNContact(firstName: "Akshit", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact2 = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri1", phoneNumbers: ["919426390589"])
//        let result2 = ContactsWorker().isMiddleNameMatched(cultivateContact: mockCULContact2, iOSContact: mockCNContact2)
//        XCTAssertTrue(result2)
//        
//        
//        let mockCNContact3 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact3 = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra1", lastName: "Zaveri", phoneNumbers: ["919426390589"])
//        let result3 = ContactsWorker().isMiddleNameMatched(cultivateContact: mockCULContact3, iOSContact: mockCNContact3)
//        XCTAssertFalse(result3)
//    }
//    
//    func testLastNameMatching() {
//        let mockCNContact = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["919426390589"])
//        let result = ContactsWorker().isLastNameMatched(cultivateContact: mockCULContact, iOSContact: mockCNContact)
//        XCTAssertTrue(result)
//        
//        
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact1 = self.mockCULContact(firstName: "Zaveri", lastName: "Akshit", phoneNumbers: ["919426390589"])
//        let result1 = ContactsWorker().isLastNameMatched(cultivateContact: mockCULContact1, iOSContact: mockCNContact1)
//        XCTAssertFalse(result1)
//        
//        
//        let mockCNContact2 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact2 = self.mockCULContact(firstName: "Akshit", lastName: "Zaveri1", phoneNumbers: ["919426390589"])
//        let result2 = ContactsWorker().isLastNameMatched(cultivateContact: mockCULContact2, iOSContact: mockCNContact2)
//        XCTAssertFalse(result2)
//    }
//    
//    func testPhoneNumberMatching() {
//        let mockCNContact = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589", "8160696917"])
//        let mockCULContact = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["919426390589", "8866245060"])
//        
//        let result = ContactsWorker().atleastOnePhoneNumberMatchedBetween(cultivatePhoneNumbers: mockCULContact.phoneNumbers, iOSContactPhoneNumbers: mockCNContact.phoneNumbers)
//        XCTAssertTrue(result)
//        
//        
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["+91 94263 90589"])
//        let mockCULContact1 = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", phoneNumbers: ["8160696917"])
//        
//        let result1 = ContactsWorker().atleastOnePhoneNumberMatchedBetween(cultivatePhoneNumbers: mockCULContact1.phoneNumbers, iOSContactPhoneNumbers: mockCNContact1.phoneNumbers)
//        XCTAssertFalse(result1)
//    }
//    
//    func testEmailAddressMatching() {
//        let mockCNContact = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", emailAddresses: ["akshit.zaveri@gmail.com"])
//        let mockCULContact = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", emailAddresses: ["akshit.zaveri@gmail.com"])
//        
//        let result = ContactsWorker().atleastOneEmailAddressMatchedBetween(cultivateEmailAddresses: mockCULContact.emailAddresses, iOSContactEmailAddresses: mockCNContact.emailAddresses)
//        XCTAssertTrue(result)
//        
//        
//        let mockCNContact1 = self.mockCNContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", emailAddresses: ["zaveri.akshit@gmail.com"])
//        let mockCULContact1 = self.mockCULContact(firstName: "Akshit", middleName: "Dharmendra", lastName: "Zaveri", emailAddresses: ["akshit.zaveri@gmail.com"])
//        
//        let result1 = ContactsWorker().atleastOneEmailAddressMatchedBetween(cultivateEmailAddresses: mockCULContact1.emailAddresses, iOSContactEmailAddresses: mockCNContact1.emailAddresses)
//        XCTAssertFalse(result1)
//    }
//    
//    private func mockCNContact(identifier:String? = nil,
//                               firstName: String,
//                               middleName: String? = nil,
//                               lastName: String,
//                               phoneNumbers: [String] = [],
//                               emailAddresses: [String] = [] ) -> CNMutableContact {
//        
//        let cnContact = CNMutableContact()
//        
//        cnContact.givenName = firstName
//        if let middleName = middleName {
//            cnContact.middleName = middleName
//        }
//        cnContact.familyName = lastName
//        
//        var phoneNumbersToAdd = [CNLabeledValue<CNPhoneNumber>]()
//        for phoneNumber in phoneNumbers {
//            let t = CNLabeledValue<CNPhoneNumber>(label: "Phone", value: CNPhoneNumber(stringValue: phoneNumber))
//            phoneNumbersToAdd.append(t)
//        }
//        cnContact.phoneNumbers = phoneNumbersToAdd
//        
//        var emailsToAdd = [CNLabeledValue<NSString>]()
//        for email in emailAddresses {
//            let t = CNLabeledValue<NSString>(label: "Email", value: email as NSString)
//            emailsToAdd.append(t)
//        }
//        cnContact.emailAddresses = emailsToAdd
//        
//        return cnContact
//    }
//    
//    private func mockCULContact(identifier: String? = nil,
//                                firstName: String? = nil,
//                                middleName: String? = nil,
//                                lastName: String? = nil,
//                                phoneNumbers: [String] = [],
//                                emailAddresses: [String] = []) -> CULContact {
//        
//        var contact = CULContact()
//        contact.identifier = identifier
//        contact.first_name = firstName
//        contact.middle_name = middleName
//        contact.last_name = lastName
//        contact.phoneNumbers = phoneNumbers
//        contact.emailAddresses = emailAddresses
//        return contact
//    }
//}
//
//
//extension ContactsWorkerTests {
//    
//    func testGetUnlinkedContacts() {
//        let mockCULContact0 = self.mockCULContact(identifier: "mockId",
//                                                  firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ ],
//                                                  emailAddresses: [ ])
//        let mockCULContact1 = self.mockCULContact(identifier: "mockId1",
//                                                  firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ ],
//                                                  emailAddresses: [ ])
//        let mockCULContact2 = self.mockCULContact(firstName: "Akshit",
//                                                  middleName: "D",
//                                                  lastName: "Zaveri",
//                                                  phoneNumbers: [ ],
//                                                  emailAddresses: [ ])
//        let mockContacts = [ mockCULContact0, mockCULContact1, mockCULContact2 ]
//        let contacts = MockContactsWorker().getUnlinkedContacts(from: mockContacts)
//        XCTAssertEqual(contacts.count, 2)
//        XCTAssertEqual(contacts.first!.identifier, mockCULContact1.identifier)
//        XCTAssertEqual(contacts[1].identifier, nil)
//    }
//    
//    func testPerformanceGetUnlinkedContacts() {
//        self.measure {
//            let mockCULContact0 = self.mockCULContact(identifier: "mockId",
//                                                      firstName: "Akshit",
//                                                      middleName: "D",
//                                                      lastName: "Zaveri",
//                                                      phoneNumbers: [ ],
//                                                      emailAddresses: [ ])
//            let mockCULContact1 = self.mockCULContact(identifier: "mockId1",
//                                                      firstName: "Akshit",
//                                                      middleName: "D",
//                                                      lastName: "Zaveri",
//                                                      phoneNumbers: [ ],
//                                                      emailAddresses: [ ])
//            let mockCULContact2 = self.mockCULContact(firstName: "Akshit",
//                                                      middleName: "D",
//                                                      lastName: "Zaveri",
//                                                      phoneNumbers: [ ],
//                                                      emailAddresses: [ ])
//            let mockContacts = [ mockCULContact0, mockCULContact1, mockCULContact2 ]
//            let contacts = MockContactsWorker().getUnlinkedContacts(from: mockContacts)
//            XCTAssertEqual(contacts.count, 2)
//            XCTAssertEqual(contacts.first!.identifier, mockCULContact1.identifier)
//            XCTAssertEqual(contacts[1].identifier, nil)
//        }
//    }
//}
//
//class MockContactsWorker: ContactsWorker {
//    override func getCNContact(for identifier: String) -> CNContact? {
//        if identifier == "mockId" {
//            return CNContact()
//        }
//        return nil
//    }
//}

