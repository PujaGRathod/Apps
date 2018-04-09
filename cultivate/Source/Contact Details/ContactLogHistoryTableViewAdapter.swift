//
//  ContactLogHistoryTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 17/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class ContactLogHistoryTableViewAdapter: NSObject {
    
    private var tableView: UITableView!
    private var followups = [CULContact.Followup]()
    var historyLoaded: (()->Void)?
    
    func set(tableView: UITableView, contact: CULContact) {
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getFollowupHistory(for: contact)
        
        self.sortFollowups()
        
        let nib = UINib(nibName: "ContactHistoryTblCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ContactHistoryTblCell")
    }
    
    func getFollowupHistory(for contact: CULContact) {
        guard let user = CULFirebaseGateway.shared.loggedInUser else {
            self.followups = []
            self.tableView.reloadData()
            self.historyLoaded?()
            return
        }
        CULFirebaseGateway.shared.getFollowups(for: contact, loggedInUser: user) { (followups, error) in
            DispatchQueue.main.async {
                self.followups = followups
                self.sortFollowups()
                self.tableView.reloadData()
                self.historyLoaded?()
            }
        }
    }
    
    func sortFollowups() {
        self.followups.sort(by: { (followup1, followup2) -> Bool in
            if let date1 = followup1.date, let date2 = followup2.date {
                return date1 > date2
            }
            return false
        })
    }
}

extension ContactLogHistoryTableViewAdapter: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactHistoryTblCell", for: indexPath) as! ContactHistoryTblCell
        cell.set(followup: self.followups[indexPath.item])
        return cell
    }
}
