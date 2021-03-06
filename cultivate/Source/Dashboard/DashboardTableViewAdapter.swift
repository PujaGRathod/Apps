//
//  DashboardTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 11/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

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
    
    private var contacts = [CULContact]()
    private var filteredContacts = [CULContact]()
    private var sectionWiseContacts = [Section]()
    private var firstLogFollowupButton: UIButton?
    
    private var tableView: UITableView!
    private var searchController: UISearchController?
    
    var contactsLoaded: (([CULContact])->Void)?
    var contactSelected: ((_ contact: CULContact)->Void)?
    var shouldExpandOtherFollowupSection = false
    var followupButtonTapped: ((_ indexPath: IndexPath, _ contact: CULContact)->Void)?
    var rescheduleButtonTapped: ((_ indexPath: IndexPath, _ contact: CULContact)->Void)?
    
    func setup(for tableView: UITableView, searchController: UISearchController) {
        self.tableView = tableView
        
        let nib = UINib(nibName: "DashboardContactTblCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DashboardContactTblCell")
        
        let nib1 = UINib(nibName: "DashboardTableViewHeader", bundle: nil)
        self.tableView.register(nib1, forHeaderFooterViewReuseIdentifier: "DashboardTableViewHeader")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = 66
        
        self.searchController = searchController
        self.searchController?.searchBar.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
    }
    
    func getContacts() {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                
                CULFirebaseAnalyticsManager.shared.set(property: .totalNumberOfCultivateContacts, value: contacts.count)
                
                DispatchQueue.main.async {
                    self.contacts = contacts
                    self.updateContactsIfRequired()
                    self.formatContactsForAdapter()
                    self.contactsLoaded?(contacts)
                }
            })
        }
    }
    
    private func updateContactsIfRequired() {
        self.contacts = FollowupDateGenerator.assignInitialFollowupDates(for: self.contacts)
        
        if let user = CULFirebaseGateway.shared.loggedInUser {
            CULFirebaseGateway.shared.update(contacts: self.contacts, for: user, completion: { (error) in
                print("Contacts saved - DashboardTableViewAdapter")
            })
        }
        
        self.sortContacts()
    }
    
    func update(contacts: [CULContact]) {
        for contact in contacts {
            if let index = self.contacts.index(of: contact) {
                self.contacts[index] = contact
            }
        }
        self.reloadData()
    }
    
    func update(contact: CULContact) {
        if let index = self.contacts.index(of: contact) {
            self.contacts[index] = contact
        }
        self.reloadData()
    }

    func reloadData() {
        self.sortContacts()
        self.formatContactsForAdapter()
    }
    
    private func sortContacts() {
        self.contacts.sort { (contact1, contact2) -> Bool in
            if let date1 = contact1.followupDate, let date2 = contact2.followupDate {
                return date1 < date2
            }
            return false
        }
    }
    
    private func formatContactsForAdapter() {
        
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
        section1.title = "Follow-ups for the next 30 days"
        var rows1 = [Section.Row]()
        for (index, contact) in followupsInNext30Days.enumerated() {
            rows1.append(Section.Row(index: index, contact: contact))
        }
        section1.rows = rows1
        
        
        var section2 = Section()
        section2.title = "All other follow-ups"
        section2.index = 1
        var rows2 = [Section.Row]()
        for (index, contact) in restOfFollowups.enumerated() {
            rows2.append(Section.Row(index: index, contact: contact))
        }
        section2.rows = rows2
        
        self.sectionWiseContacts = [ section1, section2 ]
        
        if section1.rows.count > 0 {
            self.shouldExpandOtherFollowupSection = false
        } else {
            self.shouldExpandOtherFollowupSection = true
        }
        
        self.tableView.reloadData()
    }
    
    func getFirstLogFollowupButton() -> UIButton? {
        return self.firstLogFollowupButton
    }
}

extension DashboardTableViewAdapter: UITableViewDataSource, UITableViewDelegate {
    
    private func contact(for indexPath: IndexPath) -> CULContact {
        if self.isFiltering() {
            return self.filteredContacts[indexPath.item]
        } else {
            return self.sectionWiseContacts[indexPath.section].rows[indexPath.item].contact
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFiltering() {
            return 1
        }
        return self.sectionWiseContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredContacts.count
        }
        if section == 1, self.shouldExpandOtherFollowupSection == false {
            return 0
        }
        return self.sectionWiseContacts[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardContactTblCell", for: indexPath) as! DashboardContactTblCell
        cell.set(contact: self.contact(for: indexPath))
        cell.followupButtonTapped = { contact in
            self.followupButtonTapped?(indexPath, contact)
        }
        if indexPath.item == 0 {
            if indexPath.section == 0 {
                self.firstLogFollowupButton = cell.logFollowupButton
            }
            if indexPath.section == 1, self.firstLogFollowupButton == nil {
                self.firstLogFollowupButton = cell.logFollowupButton
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isFiltering() {
            return 0
        }
        return 28 + 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.isFiltering() {
            return nil
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardTableViewHeader") as! DashboardTableViewHeader
        let title = self.sectionWiseContacts[section].title
        headerView.set(title: title, index: section)
        if section == 1, self.shouldExpandOtherFollowupSection == false {
            headerView.setButtonVisibility(to: true)
        } else {
            headerView.setButtonVisibility(to: false)
        }
        headerView.headerTapped = { index in
            if index == 1 {
                self.shouldExpandOtherFollowupSection = !self.shouldExpandOtherFollowupSection
                self.tableView.reloadData()
            }
        }
        return headerView
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reschedule = UIContextualAction(style: UIContextualAction.Style.normal, title: "Reschedule") { (action, view, completionHandler) in
            let contact = self.contact(for: indexPath)
            self.rescheduleButtonTapped?(indexPath, contact)
            completionHandler(true)
        }
        reschedule.backgroundColor = UIColor.red
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [reschedule])
        swipeActionConfig.performsFirstActionWithFullSwipe = true
        return swipeActionConfig
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reschedule = UITableViewRowAction(style: .normal, title: "Reschedule") { action, index in
            let contact = self.contact(for: indexPath)
            self.rescheduleButtonTapped?(indexPath, contact)
        }
        reschedule.backgroundColor = UIColor.red
        
        return [reschedule]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contactSelected?(self.contact(for: indexPath))
    }
}

extension DashboardTableViewAdapter {
    
    func set(searchController: UISearchController) {
        self.searchController = searchController
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredContacts = self.contacts.filter({ (contact) -> Bool in
            let nameMatched = contact.name.lowercased().contains(searchText.lowercased())
            if let tagName = contact.tag?.name {
                let tagMatched = tagName.lowercased().contains(searchText.lowercased())
                return nameMatched || tagMatched
            }
            return nameMatched
        })
        self.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return self.searchController?.isActive ?? false && !self.searchBarIsEmpty()
    }
}

extension DashboardTableViewAdapter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}


