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
    private var filteredTags: [CULTag] = []
    private var contact: CULContact!
    private var selectedTag: CULTag?
    private var searchText: String = ""
    private var tableView: UITableView!
    
    var delegate: TagsListTableViewAdapterDelegate?
    
    func set(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tags = self.getTags()
        self.filteredTags = self.tags
        
        self.tableView.reloadData()
    }
    
    // TODO: get the data from Firebase
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
        self.tableView.reloadData()
    }
    
    // TODO: change this function to add tag to Firebase
    func add(tag name: String) -> CULTag {
        let indentifier: String = "\(Date.timeIntervalSinceReferenceDate)"
        let tag: CULTag = CULTag(identifier: indentifier, name: name)
        self.tags.append(tag)
        
        self.tableView.reloadData()
        
        return tag
    }
    
    func search(tag name: String) {
        self.searchText = name
        if name.count == 0 {
            self.filteredTags = self.tags
        } else {
            self.filteredTags = self.tags.filter { (tag) -> Bool in
                return tag.name.lowercased().contains(name.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    func filteredTagsCount() -> Int {
        return self.filteredTags.count
    }
}

extension TagsListTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    func tag(for indexPath: IndexPath) -> CULTag? {
        return self.filteredTags[indexPath.item]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredTags.count == 0 {
            return 1
        }
        return self.filteredTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        
        if self.filteredTags.count == 0 {
            cell.textLabel?.text = "Tap to create a new tag"
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17)
        } else {
            let tag: CULTag? = self.tag(for: indexPath)
            cell.textLabel?.text = tag?.name ?? "N.A"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            
            if self.contact.tag?.identifier == tag?.identifier {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filteredTags.count == 0 {
            let tag: CULTag = self.add(tag: self.searchText)
            self.delegate?.selected(tag: tag, for: self.contact)
        } else {
            // Call delegate method
            if let tag:CULTag = self.tag(for: indexPath) {
                self.delegate?.selected(tag: tag, for: self.contact)
            } else {
                // How could this happen?
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
