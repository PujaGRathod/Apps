//
//  CULContact.swift
//  cultivate
//
//  Created by Akshit Zaveri on 19/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import Foundation

enum CULFollowupFrequency {
    case two_weeks
    case one_month
    case two_months
    case three_months
    case four_months
    case six_months
    case one_year
    case none
    
    var values: (days: Int, weeks: Int, months: Int, years: Int, description: String) {
        switch self {
        case .two_weeks:
            return (0, 2, 0, 0, "Every two weeks")
        case .one_month:
            return (0, 0, 1, 0, "Every month")
        case .two_months:
            return (0, 0, 2, 0, "Every 2 months")
        case .three_months:
            return (0, 0, 3, 0, "Every 3 months")
        case .four_months:
            return (0, 0, 4, 0, "Every 4 months")
        case .six_months:
            return (0, 0, 6, 0, "Every 6 months")
        case .one_year:
            return (0, 0, 0, 1, "Every year")
        default:
            return (0, 0, 0, 0, "None")
        }
    }
}

class CULContact {
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
    var tag: CULTag?
}

struct CULTag {
    var identifier: String!
    var name: String!
}
