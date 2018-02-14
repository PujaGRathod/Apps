//
//  CULContact.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

enum CULFollowupFrequency: String {
    case two_weeks = "two_weeks"
    case one_month = "one_month"
    case two_months = "two_months"
    case three_months = "three_months"
    case four_months = "four_months"
    case six_months = "six_months"
    case one_year = "one_year"
    case none = "none"
    
    struct Period {
        var days: Int
        var weeks: Int
        var months: Int
        var years: Int
        var description: String
        
//        var totalDays: Int {
//            let days = self.days
//            let daysInWeeks = self.weeks*7
//            let daysInMonth = Int(Double(self.months)*30.42)
//            let daysInYears = self.years*365
//            return days + daysInWeeks + daysInMonth + daysInYears
//        }
        
        func totalDaysFromToday() -> Int? {
            let date = Date()
            if let maximumDate = self.dateByAddingComponentsTo(date) {
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let components = calendar.dateComponents([.day], from: date, to: maximumDate)
                return components.day
            }
            return nil
        }
        
        func dateByAddingComponentsTo(_ date: Date) -> Date? {
            
            var unit: Calendar.Component!
            var value: Int!
            if self.days > 0 {
                unit = Calendar.Component.day
                value = self.days
            } else if self.weeks > 0 {
                unit = Calendar.Component.day
                value = self.weeks * 7
            } else if self.months > 0 {
                unit = Calendar.Component.month
                value = self.months
            } else if self.years > 0 {
                unit = Calendar.Component.year
                value = self.years
            } else {
                return nil
            }
            
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            return calendar.date(byAdding: unit, value: value, to: date)
        }
    }
    
    var values: Period {
        switch self {
        case .two_weeks:
            return Period(days: 0, weeks: 2, months: 0, years: 0, description: "Every two weeks")
        case .one_month:
            return Period(days: 0, weeks: 0, months: 1, years: 0, description: "Every month")
        case .two_months:
            return Period(days: 0, weeks: 0, months: 2, years: 0, description: "Every 2 months")
        case .three_months:
            return Period(days: 0, weeks: 0, months: 3, years: 0, description: "Every 3 months")
        case .four_months:
            return Period(days: 0, weeks: 0, months: 4, years: 0, description: "Every 4 months")
        case .six_months:
            return Period(days: 0, weeks: 0, months: 6, years: 0, description: "Every 6 months")
        case .one_year:
            return Period(days: 0, weeks: 0, months: 0, years: 1, description: "Every year")
        default:
            return Period(days: 0, weeks: 0, months: 0, years: 0, description: "None")
        }
    }
}

struct CULContact: Equatable {
 
    enum SortOrder: Int {
        case firstName = 1
        case lastName = 2
    }
    
    static func ==(lhs: CULContact, rhs: CULContact) -> Bool {
        return lhs.db_Identifier == rhs.db_Identifier
    }
    
    struct Followup {
        var date: Date?
        var notes: String?
        
        var userReadableDateString: String {
            if let date = self.date {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                return df.string(from: date)
            }
            return ""
        }
    }
    
    // Database identifier. E.g Firebase
    var db_Identifier: String?
    
    // Contact book identifier
    var identifier: String!
    
//    var profileImageURL: URL?
    var profileImage: UIImage?
    
    var first_name: String?
    var last_name: String?
    var name: String {
        var list: [String] = []
        if let fName: String = self.first_name,
            self.first_name?.isEmpty == false {
            
            list.append(fName)
        }
        if let lName: String = self.last_name,
            self.last_name?.isEmpty == false {
            
            list.append(lName)
        }
        
        return list.joined(separator: " ")
    }
    
    var initials: String {
        var initialsList = [Character]()
        if let a = self.first_name?.first {
            initialsList.append(a)
        }
        if let a = self.last_name?.first {
            initialsList.append(a)
        }
        return String(initialsList)
    }
    
    var followupFrequency: CULFollowupFrequency = CULFollowupFrequency.none
    var followupDate: Date?
    var userReadableFollowupDateString: String {
        if let date = self.followupDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: date)
        }
        return ""
    }
    
    var tag: CULTag?
    var followups = [Followup]()
    var notes: String?
    
    /* Extra properties saved for contact matching */
    var middle_name: String?
    var phoneNumbers = [String]()
    var emailAddresses = [String]()
}

struct CULTag {
    var identifier: String!
    var name: String!
}
