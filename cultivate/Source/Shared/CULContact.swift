//
//  CULContact.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import Foundation

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
        
        var totalDays: Int {
            let days = self.days
            let daysInWeeks = self.weeks*7
            let daysInMonth = Int(Double(self.months)*30.42)
            let daysInYears = self.years*365
            return days + daysInWeeks + daysInMonth + daysInYears
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

//TODO: Change this to struct
class CULContact {
 
    struct Followup {
        var date: Date?
    }
    
    var db_Identifier: String!
    var identifier: String!
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
    
    var followupFrequency: CULFollowupFrequency = CULFollowupFrequency.none
    var followupDate: Date?
    var tag: CULTag?
    var followups = [Followup]()
}

struct CULTag {
    var identifier: String!
    var name: String!
}
