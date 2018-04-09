//
//  CULNotificationsManager.swift
//  cultivateTests
//
//  Created by Akshit Zaveri on 06/03/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import XCTest
@testable import cultivate

class CULNotificationsManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWeeklyFrequencyNotificationSameDayAndTime() {
        let mockFrequency = NotificationSettings.Frequency.monday
        let mockNotificationTime = "09:00"
        let startDate = Date.init(timeIntervalSince1970: 1546831800) // Jan 7 2019, 09:00:00 AM
        let expectedResult = Date.init(timeIntervalSince1970: 1546831800) // Jan 7 2019, 09:00:00 AM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testNotificationsListDaily() {
        let mockContacts = [
            mockContact(followupDateTimeInterval: 1520015399), // Mar 2 2019, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520274599), // Mar 5 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520360999), // Mar 6 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1521138599), // Mar 15 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523471399), // Apr 11 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523435399), // Apr 11 2018, 01:59:59 PM
            mockContact(followupDateTimeInterval: 1523557799), // Apr 12 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523521799), // Apr 12 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523694599), // Apr 14 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523780999), // Apr 15 2018, 1:59:59 PM
        ]
        let mockToday = Date.init(timeIntervalSince1970: 1520306940) // Mar 6 2018, 08:59:00 AM
        let mockNotificationSettings = NotificationSettings(time: "09:00", frequency: NotificationSettings.Frequency.daily)
        let result = CULNotificationsManager.shared.getNotificationsToSchedule(with: mockContacts, notificationSettings: mockNotificationSettings, today: mockToday)
        
        XCTAssertEqual(result.count, 6)
        
        XCTAssertEqual(result[0].dueFollowupsCount, 1)
        XCTAssertEqual(result[0].overdueFollowupsCount, 2)
        
        XCTAssertEqual(result[1].dueFollowupsCount, 1)
        XCTAssertEqual(result[1].overdueFollowupsCount, 3)
        
        XCTAssertEqual(result[2].dueFollowupsCount, 2)
        XCTAssertEqual(result[2].overdueFollowupsCount, 4)
        
        XCTAssertEqual(result[3].dueFollowupsCount, 2)
        XCTAssertEqual(result[3].overdueFollowupsCount, 6)
        
        XCTAssertEqual(result[4].dueFollowupsCount, 1)
        XCTAssertEqual(result[4].overdueFollowupsCount, 8)
        
        XCTAssertEqual(result[5].dueFollowupsCount, 1)
        XCTAssertEqual(result[5].overdueFollowupsCount, 9)
    }

    func testNotificationsListWeeklyMonday() {
        let mockContacts = [
            mockContact(followupDateTimeInterval: 1520015399), // Mar 2 2019, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520274599), // Mar 5 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520360999), // Mar 6 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1521138599), // Mar 15 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523471399), // Apr 11 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523435399), // Apr 11 2018, 01:59:59 PM
            mockContact(followupDateTimeInterval: 1523557799), // Apr 12 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523521799), // Apr 12 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523694599), // Apr 14 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523780999), // Apr 15 2018, 1:59:59 PM
        ]
        let mockToday = Date.init(timeIntervalSince1970: 1520306940) // Mar 6 2018, 08:59:00 AM
        let mockNotificationSettings = NotificationSettings(time: "09:00", frequency: NotificationSettings.Frequency.monday)
        let result = CULNotificationsManager.shared.getNotificationsToSchedule(with: mockContacts, notificationSettings: mockNotificationSettings, today: mockToday)
        
        XCTAssertEqual(result.count, 2)
        
        XCTAssertEqual(result[0].dueFollowupsCount, 1)
        XCTAssertEqual(result[0].overdueFollowupsCount, 3)
        
        XCTAssertEqual(result[1].dueFollowupsCount, 6)
        XCTAssertEqual(result[1].overdueFollowupsCount, 4)
    }
    
    func testNotificationsListWeeklyFriday() {
        let mockContacts = [
            mockContact(followupDateTimeInterval: 1520015399), // Mar 2 2019, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520274599), // Mar 5 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1520360999), // Mar 6 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1521138599), // Mar 15 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523471399), // Apr 11 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523435399), // Apr 11 2018, 01:59:59 PM
            mockContact(followupDateTimeInterval: 1523557799), // Apr 12 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1523521799), // Apr 12 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523694599), // Apr 14 2018, 1:59:59 PM
            mockContact(followupDateTimeInterval: 1523780999), // Apr 15 2018, 1:59:59 PM
        ]
        let mockToday = Date.init(timeIntervalSince1970: 1520306940) // Mar 6 2018, 08:59:00 AM
        let mockNotificationSettings = NotificationSettings(time: "09:00", frequency: NotificationSettings.Frequency.friday)
        let result = CULNotificationsManager.shared.getNotificationsToSchedule(with: mockContacts, notificationSettings: mockNotificationSettings, today: mockToday)
        
        XCTAssertEqual(result.count, 3)
        
        XCTAssertEqual(result[0].dueFollowupsCount, 1)
        XCTAssertEqual(result[0].overdueFollowupsCount, 3)
        
        XCTAssertEqual(result[1].dueFollowupsCount, 4)
        XCTAssertEqual(result[1].overdueFollowupsCount, 4)
        
        XCTAssertEqual(result[2].dueFollowupsCount, 2)
        XCTAssertEqual(result[2].overdueFollowupsCount, 8)
    }

    
    func testDailyFrequencyNotificationSameDay() {
        let mockFrequency = NotificationSettings.Frequency.daily
        let mockNotificationTime = "19:00"
        let startDate = Date.init(timeIntervalSince1970: 1520329721) // Mar 6 2018, 3:18:41 PM
        let expectedResult = Date.init(timeIntervalSince1970: 1520343000) // Mar 6 2018, 7:00:00 PM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testDailyFrequencyNotificationNextDay() {
        let mockFrequency = NotificationSettings.Frequency.daily
        let mockNotificationTime = "09:00"
        let startDate = Date.init(timeIntervalSince1970: 1520329721) // Mar 6 2018, 3:18:41 PM
        let expectedResult = Date.init(timeIntervalSince1970: 1520393400) // Mar 7 2018, 9:00:00 AM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testWeeklyFrequencyNotificationCurrentDay() {
        let mockFrequency = NotificationSettings.Frequency.tuesday
        let mockNotificationTime = "23:00"
        let startDate = Date.init(timeIntervalSince1970: 1520329721) // Mar 6 2018, 3:18:41 PM
        let expectedResult = Date.init(timeIntervalSince1970: 1520357400) // Mar 6 2018, 11:00:00 PM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testWeeklyFrequencyNotificationNextMonday() {
        let mockFrequency = NotificationSettings.Frequency.monday
        let mockNotificationTime = "09:00"
        let startDate = Date.init(timeIntervalSince1970: 1520329721) // Mar 6 2018, 3:18:41 PM
        let expectedResult = Date.init(timeIntervalSince1970: 1520825400) // Mar 12 2018, 9:00:00 AM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testWeeklyFrequencyNotificationNextYearMonday() {
        let mockFrequency = NotificationSettings.Frequency.monday
        let mockNotificationTime = "09:00"
        let startDate = Date.init(timeIntervalSince1970: 1546256921) // Dec 31 2018, 5:18:41 PM
        let expectedResult = Date.init(timeIntervalSince1970: 1546831800) // Jan 7 2019, 09:00:00 AM
        let result = CULNotificationsManager.shared.getNextDateFor(frequency: mockFrequency, after: startDate, notificationTime: mockNotificationTime)
        XCTAssertEqual(expectedResult, result)
    }
    
    func testFollowupCountBetweenDates1() {
        let contacts = [
            mockContact(followupDateTimeInterval: 1546831800), // Jan 7 2019, 9:00:00 AM
            mockContact(followupDateTimeInterval: 1548268199), // Jan 23 2019, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1516732199), // Jan 23 2018, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1546972199), // Jan 8 2019, 11:59:59 PM
            mockContact(followupDateTimeInterval: 1547188199) // Jan 11 2019, 11:59:59 AM
        ]
        let sinceDate = Date.init(timeIntervalSince1970: 1546799400) // Jan 7 2019, 12:00:00 AM
        let toDate = Date.init(timeIntervalSince1970: 1547404199) // Jan 13 2019, 11:59:59 PM
        let expectedResult = 3
        let result = CULNotificationsManager.shared.getFollowupCounts(from: contacts, since: sinceDate, to: toDate)
        XCTAssertEqual(expectedResult, result)
    }
    
    private func mockContact(followupDateTimeInterval: TimeInterval) -> CULContact {
        var contact = CULContact()
        contact.followupDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date.init(timeIntervalSince1970: followupDateTimeInterval))
        return contact
    }
}
