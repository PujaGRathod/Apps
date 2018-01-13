//
//  DashboardTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

protocol DashboardTableViewAdapterDelegate {
    
}

class DashboardTableViewAdapter: NSObject {

    struct Section {
        var index: Int?
        var title: String = ""
        var rows = [Row]()
        struct Row {
            var index: Int?
            var contact: CULContact
        }
    }
    
    private var contacts: [CULContact] = []
    private var sectionWiseContacts: [Section] = []
    
    private var tableView: UITableView!
    private var delegate: DashboardTableViewAdapterDelegate?
    
    func setup(for tableView: UITableView, delegate: DashboardTableViewAdapterDelegate) {
        self.delegate = delegate
        self.tableView = tableView
        
        let nib = UINib(nibName: "DashboardContactTblCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DashboardContactTblCell")
        
        let nib1 = UINib(nibName: "DashboardTableViewHeader", bundle: nil)
        self.tableView.register(nib1, forHeaderFooterViewReuseIdentifier: "DashboardTableViewHeader")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getContacts()
    }
    
    func getContacts() {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                DispatchQueue.main.async {
                    self.contacts = contacts
                    self.formatContactsForAdapter()
                }
            })
        }
    }
    
    private func formatContactsForAdapter() {
        self.contacts = FollowupDateGenerator.assignInitialFollowupDates(for: self.contacts)
        
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: self.contacts, for: user, completion: { (error) in
                print("Contacts saved - DashboardTableViewAdapter")
            })
        }
        
        self.contacts.sort { (contact1, contact2) -> Bool in
            if let date1 = contact1.followupDate, let date2 = contact2.followupDate {
                return date1 < date2
            }
            return false
        }
        
        var followupsInNext30Days = [CULContact]()
        var restOfFollowups = [CULContact]()
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var datecomponents = calendar.dateComponents([ .day, .month, .year, .hour, .minute, .second ], from: Date())
        datecomponents.day = (datecomponents.day ?? 0) + 30
        datecomponents.hour = 23
        datecomponents.minute = 59
        datecomponents.second = 59
        let dateAfter30DaysFromToday = calendar.date(from: datecomponents)
        
        // Parting the sections
        for contact in self.contacts {
            if let followupDate = contact.followupDate,
                let dateAfter30Days = dateAfter30DaysFromToday,
                followupDate <= dateAfter30Days {
                
                followupsInNext30Days.append(contact)
            } else {
                restOfFollowups.append(contact)
            }
        }
        
        var section1 = Section()
        section1.index = 0
        section1.title = "Suggested follow-ups for the next 30 days"
        var rows1 = [Section.Row]()
        for (index, contact) in followupsInNext30Days.enumerated() {
            rows1.append(Section.Row(index: index, contact: contact))
        }
        section1.rows = rows1
        
        
        var section2 = Section()
        section2.title = "All other suggested follow-ups"
        section2.index = 1
        var rows2 = [Section.Row]()
        for (index, contact) in restOfFollowups.enumerated() {
            rows2.append(Section.Row(index: index, contact: contact))
        }
        section2.rows = rows2
        
        self.sectionWiseContacts = [ section1, section2 ]
        
        self.tableView.reloadData()
    }
}

extension DashboardTableViewAdapter: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionWiseContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionWiseContacts[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardContactTblCell", for: indexPath) as! DashboardContactTblCell
        let contact = self.sectionWiseContacts[indexPath.section].rows[indexPath.item].contact
        cell.set(contact: contact)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 + 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardTableViewHeader") as! DashboardTableViewHeader
        headerView.titleLabel.text = self.sectionWiseContacts[section].title
        return headerView
    }
}
