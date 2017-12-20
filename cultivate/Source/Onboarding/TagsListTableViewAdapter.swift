//
//  TagsListTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit

protocol TagsListTableViewAdapterDelegate {
    func selected(tag: CULTag, for contact: CULContact)
}

class TagsListTableViewAdapter: NSObject {

    private var tags: [CULTag] = []
    private var contact: CULContact!
    private var selectedTag: CULTag?
    private var tableView: UITableView!
    
    var delegate: TagsListTableViewAdapterDelegate?
    
    func set(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tags = self.getTags()
        
        self.tableView.reloadData()
    }
    
    // Eventually get the data from Firebase here
    private func getTags() -> [CULTag] {
        return [
            CULTag(identifier: "1", name: "Family"),
            CULTag(identifier: "2", name: "Office"),
            CULTag(identifier: "3", name: "Football team"),
            CULTag(identifier: "4", name: "Surfing buddies"),
            CULTag(identifier: "5", name: "Mentors")
        ]
    }
    
    func set(contact: CULContact) {
        self.contact = contact
        self.selectedTag = nil
    }
}

extension TagsListTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    func tag(for indexPath: IndexPath) -> CULTag? {
        return self.tags[indexPath.item]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.tag(for: indexPath)?.name ?? "N.A"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Call delegate method
        if let tag:CULTag = self.tag(for: indexPath) {
            self.delegate?.selected(tag: tag, for: self.contact)
        } else {
            // How could this happen?
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
