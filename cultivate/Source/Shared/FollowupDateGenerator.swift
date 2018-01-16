//
//  FollowupDateGenerator.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import Foundation

class FollowupDateGenerator {
    
    static private var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    static private var allDateComponents: Set<Calendar.Component> = [ .day, .month, .year, .hour, .minute, .second]
    
    /*
     Case 1: When a contact is added to the Cultivate Contacts, they will be automatically assigned an Initial Follow-Up Date
     
     "● The Initial Follow-Up Date is scheduled randomly within the user defined Follow-Up Frequency interval.
     ● For example, let's assume that a User completes onboarding on January 1st, 2018. Cultivate Contacts that are assigned a Follow-Up Frequency of 6 months will be randomly assigned an Initial Follow-Up dates scattered within the next 6 months (January 1st 2018 --> July 1st 2018). For example, If there were three Cultivate Contacts assigned a follow up frequency of 6 months, the three contacts could be randomly assigned Initial Follow-Up Dates of January 29th, April 4th, and June 1st. Similarly, Cultivate Contacts that are assigned a Follow-Up Frequencies of 3 months will be randomly assigned Initial Follow-Up dates within the next 3 months (January 1st 2018 --> April 1st 2018).
     ● The initial follow-up for new Cultivate contact who is added after onboardiong will be also randomly scheduled within the selected Follow-Up Interval. For example, if a contact is given a follow-up frequency of 3 months, the initial contact for that User will be scheduled randomly for some day within the next three months."
     */
    
    class func assignInitialFollowupDates(for contacts: [CULContact]) -> [CULContact] {
        /*
         1. Get all the contacts
         2. Generate random followup date based on the follow up frequency
         2.1 Get total number of days in the follow up frequency
         2.2 Generate a random number (randon_days) in range of 0 to number of days from the step above
         3. If the followup date is set
         3.1 No, add random_days to the today's date, and generate followup_date
         3.2 Yes, Skip the contact
         4. Assign followup_date to the contact
         5. Do this for all contacts
         */
        
        var assignedContacts = [CULContact]()
        for contact in contacts {
            let values = contact.followupFrequency.values
            let totalDays = values.totalDays
            let random_days = self.generateRandomNumber(between: 0, totalDays)
            if contact.followupDate == nil {
                var datecomponents = self.calendar.dateComponents(self.allDateComponents, from: Date())
                if var days = datecomponents.day {
                    days += random_days
                    datecomponents.day = days
                } else {
                    assignedContacts.append(contact)
                    continue
                }
                let followupDate = self.calendar.date(from: datecomponents)
                
                var assignedContact = contact
                assignedContact.followupDate = followupDate
                assignedContacts.append(assignedContact)
                
                print("Followup date set \(String(describing: contact.followupDate)) for \(contact.name)")
            } else {
                assignedContacts.append(contact)
            }
        }
        return assignedContacts
    }
    
    /*
     Case 2: The Next Follow-Up Date for a given contact will automatically be recalculated if the user does not take action within 30 days of their schedueld Next Follow-up date.
     
     "● The Next Follow-Up Date for a given contact will automatically be recalculated for the user if the current date is 30 days past the original "Next Scheduled Follow-Up Date". In other words, the Next Scheduled Follow-Up will be recalculated if it is over 30 days overdue
     ● When a follow-up is over 30 days overdue, the app will recalculate the Next Scheduled Follow-Up by adding the number of days from the Follow-Up Frequency Interval to the current. For example, if the today is January 1st and the user has a follow-up frequency of two months, the Next Follow-Up Date will be rescheduled to March 1st. "
     */
    func updateFollowupDatesForOverdueFollowups() {
        // Use 30 days time-period to consider the followup as an overdue
    }
    
    
    /*
     Case 3: If the User logs an action for an Cultivate Contact, the Next Follow-Up Date will be automatically scheduled.
     
     "● When a user logs an action for an Cultivate Contact, the Suggested Next Follow-Up Date is calcualted as the number of days in the Follow-Up Frequency Interval added to the current date. For example, if a contact has a 3 month Follow-Up Frequency and an interaction is being logged on January 1st, the Suggested Next Follow-Up Date will be scheduled for April 1st
     ● If the User submits the interaction log without manually changing the Suggested Next Follow-Up Date, the Next Scheduled Follow-Up Date will be set as the Suggested Next Follow-Up Date"
     */
    func generateNextFollowupDate(for contact: CULContact) -> Date {
        return Date()
    }
    
    /*
     Case 4: If the User changes the Follow-Up Frequency for a given contact, the Next Scheduled Follow-Up Date may be rescheduled
     
     "● If the Follow-Up Frequency is changed on the "Contact Detail - Contact Info" screen, the Next Scheduled Follow-Up will be recalculated if the following two conditions are true: 1) the number of days between the Current Date and the Next Scheduled Folllow-up date is greater than the number of days in the newly chosen Follow-Up Frequency interval AND 2) The Next Scheduled Follow-Up Date was not manually entered.
     ● If one of these conditions is not true, the Next Scheduled Follow-Up will not be recalculated
     ● If the Next Scheduled Follow-up will be recalculated, it will be calculated as the number of days in the newly chosen Follow-Up Frequency interval plus the current day. For example, if a contact has a 3 month Follow-Up Frequency and an interaction is logged on January 1st, the next follow-up will be scheduled for April 1st"
     
     */
    func case4() {
        
    }

    
    static private func generateRandomNumber(between start: Int, _ end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}
