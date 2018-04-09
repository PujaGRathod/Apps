//
//  CULNotificationsManager.swift
//  cultivate
//
//  Created by Akshit Zaveri on 06/03/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation
import UserNotifications

class CULNotificationsManager {
    
    /*
     1. Get all the contacts and all the unique follow-up dates from them.
     2. Get the duration of the notifications. For Daily=1, Weekly=7
     3. Sort unique dates. Ascending. Nearest date at the top.
     4. Get the first notification start date based on the notification settings.
     5. Loop over all the unique follow-up dates. Set PreviousFollowups counter to 0.
     5.1 Get a new date by adding the duration in the first date.
     5.2 Get all the followups between these 2 dates
     5.2.1 If followups count is 0, skip the loop
     5.2.2 Else, create notification text as "You have ## scheduled follow-ups for this week and ## overdue follow-ups"
     5.3 Schedule the notification on the start date
     5.4 Add count of followups between the dates to PreviousFollowups counter.
     6. Exit
     */
    
    static let shared = CULNotificationsManager()
    
    //    private var contacts = [CULContact]()
    
    struct Notification {
        var date: Date
        var title: String
        var overdueFollowupsCount = 0
        var dueFollowupsCount = 0
        
        init(date: Date, title: String) {
            self.date = date
            self.title = title
        }
    }
    
    func setupLocalNotifications(for contacts: [CULContact]) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay]) {(accepted, error) in
            if accepted {
                print("Notification access granted.")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                guard let notificationSettings = self.getNotificationSettingsForCurrentUser() else {
                    return
                }
                
                let notifications = self.getNotificationsToSchedule(with: contacts, notificationSettings: notificationSettings, today: Date())
                // Schedule notifications here
                for (index, notification) in notifications.enumerated() {
                    self.schedule(notification: notification, index: index)
                }
            }
        }
    }
    
    func schedule(notification: Notification, index: Int) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: notification.date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Cultivate Relationship Manager"
        content.body = notification.title
        content.sound = UNNotificationSound.default()
        content.badge = NSNumber.init(value: notification.dueFollowupsCount + notification.overdueFollowupsCount)
        
        let request = UNNotificationRequest(identifier: "cul_\(index)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            } else {
                print("Local notification setup done on \(notification.date) ,,saying,, \(notification.title)")
            }
        }
    }
    
    func getNotificationsToSchedule(with contacts: [CULContact], notificationSettings: NotificationSettings, today: Date) -> [Notification] {
        
        var uniqueDates = self.getAllUniqueDates(from: contacts)
        uniqueDates = self.sortDatesAscending(uniqueDates)
        
        var notifications = [Notification]()
        
        guard let latestFollowupDate = uniqueDates.last else {
            return []
        }
        
        
        var startDate = Date.init(timeIntervalSince1970: 0)
        
        guard let nextDateTemp = self.getNextDateFor(frequency: notificationSettings.frequency, after: today, notificationTime: notificationSettings.time) else {
            return []
        }
        var previousFollowupsCount = self.getFollowupCounts(from: contacts, since: startDate, to: nextDateTemp)
        startDate = today
        
        var latestNotificationDate = nextDateTemp
        
        while (latestNotificationDate <= latestFollowupDate) {
            guard let nextDate = self.getNextDateFor(frequency: notificationSettings.frequency, after: latestNotificationDate, notificationTime: notificationSettings.time) else {
                continue
            }
            
            guard let nextNextDate = self.getNextDateFor(frequency: notificationSettings.frequency, after: nextDate.addingTimeInterval(1), notificationTime: notificationSettings.time) else {
                continue
            }
            
            let followupCounts = self.getFollowupCounts(from: contacts, since: nextDate, to: nextNextDate)
            if followupCounts > 0 {
                var string = "in next 7 days" // for this week
                if notificationSettings.frequency == .daily {
                    string = "in next 24 hours" // for today
                }
                var notification = Notification(date: nextDate, title: "You have \(followupCounts) scheduled follow-ups \(string) and \(previousFollowupsCount) overdue follow-ups")
                notification.overdueFollowupsCount = previousFollowupsCount
                notification.dueFollowupsCount = followupCounts
                notifications.append(notification)
            }
            
            latestNotificationDate = nextNextDate
            previousFollowupsCount += followupCounts
        }
        
        return notifications
    }
    
    func getContacts(_ completion: @escaping (([CULContact])->Void)) {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                completion(contacts)
            })
        }
    }
    
    func getAllUniqueDates(from contacts: [CULContact]) -> [Date] {
        let dates = contacts.flatMap({ $0.followupDate })
        let uniqueDatesSet = Set(dates)
        return Array(uniqueDatesSet)
    }
    
    func sortDatesAscending(_ dates: [Date]) -> [Date] {
        return dates.sorted(by: <)
    }
    
    func getNotificationSettingsForCurrentUser() -> NotificationSettings? {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            return user.notificationSettings
        }
        return nil
    }
    
    func getNextDateFor(frequency: NotificationSettings.Frequency, after date: Date, notificationTime: String) -> Date? {
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        if frequency == .daily {
            var datecomps = calendar.dateComponents([ .hour, .minute, .second, .day, .month, .year, .weekday, .weekOfYear ], from: date)
            let timeComponents = notificationTime.components(separatedBy: ":")
            if timeComponents.count == 2 {
                datecomps.hour = Int(timeComponents[0]) ?? 0
                datecomps.minute = Int(timeComponents[1]) ?? 0
                datecomps.second = 0
            }
            
            let probableStartDate = calendar.date(from: datecomps)
            if let probableStartDate = probableStartDate {
                if probableStartDate < date,
                    let day = datecomps.day {
                    datecomps.day = day + 1
                }
                return calendar.date(from: datecomps)
            }
        } else {
            let datecompsTemp = calendar.dateComponents([ .yearForWeekOfYear, .weekOfYear ], from: date)
            guard let startOfCurrentWeek = calendar.date(from: datecompsTemp) else {
                return nil
            }
            guard let indexOfDayInWeek = DateFormatter().weekdaySymbols.map({$0.lowercased()}).index(of: frequency.rawValue) else {
                return nil
            }
            
            var datecomps = calendar.dateComponents([ .hour, .minute, .second, .day, .month, .year, .weekday, .weekOfYear ], from: startOfCurrentWeek)
            let timeComponents = notificationTime.components(separatedBy: ":")
            if timeComponents.count == 2 {
                datecomps.hour = Int(timeComponents[0]) ?? 0
                datecomps.minute = Int(timeComponents[1]) ?? 0
                datecomps.second = 0
            }
            if let day = datecomps.day {
                datecomps.day = day + indexOfDayInWeek
            }
            
            if let nextNotificationDate = calendar.date(from: datecomps) {
                if nextNotificationDate < date,
                    let day = datecomps.day {
                    datecomps.day = day + 7
                }
                return calendar.date(from: datecomps)
            }
        }
        
        return nil
    }

    func getFollowupCounts(from contacts: [CULContact], since: Date, to: Date) -> Int {
        var count = 0
        for contact in contacts {
            if let followupDate = contact.followupDate,
                followupDate > since,
                followupDate < to {
                count += 1
            }
        }
        return count
    }
}
