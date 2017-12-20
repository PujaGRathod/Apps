//
//  FollowupFrequencyListTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

protocol FollowupFrequencyListTableViewAdapterDelegate {
    func selected(frequency: CULFollowupFrequency, for contact: CULContact)
}

class FollowupFrequencyListTableViewAdapter: NSObject {
    
    private var frequencies: [CULFollowupFrequency] {
        get {
            return [
                CULFollowupFrequency.two_weeks,
                CULFollowupFrequency.one_month,
                CULFollowupFrequency.two_months,
                CULFollowupFrequency.three_months,
                CULFollowupFrequency.four_months,
                CULFollowupFrequency.six_months,
                CULFollowupFrequency.one_year
            ]
        }
    }
    private var tableView: UITableView!
    private var contact: CULContact!
    private var selectedFrequency: CULFollowupFrequency?

    var delegate: FollowupFrequencyListTableViewAdapterDelegate?
    
    func set(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func set(contact: CULContact) {
        self.contact = contact
        self.selectedFrequency = nil
        self.tableView.reloadData()
    }
}

extension FollowupFrequencyListTableViewAdapter:UITableViewDelegate, UITableViewDataSource {
    
    private func frequency(for indexPath: IndexPath) -> CULFollowupFrequency {
        return self.frequencies[indexPath.item]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frequencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        
        let frequency: CULFollowupFrequency = self.frequency(for: indexPath)
        cell.textLabel?.text = frequency.values.description
        
        if self.contact.followupFrequency == frequency {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedFrequency = self.frequency(for: indexPath)
        if let selectedFrequency: CULFollowupFrequency = self.selectedFrequency {
            self.delegate?.selected(frequency: selectedFrequency, for: self.contact)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
