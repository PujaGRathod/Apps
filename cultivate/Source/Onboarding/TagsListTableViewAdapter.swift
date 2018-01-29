//
//  TagsListTableViewAdapter.swift
//  cultivate
//
//  Created by Akshit Zaveri on 20/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase

protocol TagsListTableViewAdapterDelegate {
    func tagsLoaded(_ tags: [CULTag])
    func selected(tag: CULTag?, for contact: CULContact?)
}

class TagsListTableViewAdapter: NSObject {
    
    var tags: [CULTag] = []
    private var filteredTags: [CULTag] = []
    private var contact: CULContact?
    var selectedTag: CULTag?
    private var searchText: String = ""
    private var tableView: UITableView!
    var textField: UITextField?
    var shouldUseCustomCell: Bool = false
    var delegate: TagsListTableViewAdapterDelegate?
    var shouldShowSelection = true
    
    func set(tableView: UITableView) {
        self.tableView = tableView
        
        if self.shouldUseCustomCell {
            let nib = UINib(nibName: "TagPickerTblCell", bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: "cell")
        } else {
            self.textField?.textAlignment = .left
            self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        }
        self.tableView.rowHeight = 44
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupTextField() {
        guard let textField = self.textField else {
            return
        }
        
        if self.shouldUseCustomCell {
            textField.textAlignment = .center
            
            let text = "Add tag"
            let attributes: [NSAttributedStringKey:Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17).boldItalic,
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
            ]
            textField.attributedPlaceholder = NSMutableAttributedString(string: text, attributes: attributes)
            textField.leftView = nil
            textField.leftViewMode = .never
        } else {
            var color = UIColor.gray
            if self.tags.count == 0 {
                color = UIColor.black
            }
            let attributes: [NSAttributedStringKey:Any] = [
                NSAttributedStringKey.foregroundColor: color
            ]
            textField.attributedPlaceholder = NSMutableAttributedString(string: "Add tags", attributes: attributes)
        }
    }
    
    func loadAllAvailableTags(_ completion: (()->Void)? = nil) {
        self.getTags { (tags) in
            self.load(tags: tags, {
                completion?()
            })
        }
    }
    
    func load(tags: [CULTag], _ completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            self.delegate?.tagsLoaded(tags)
            self.tags = tags
            self.filteredTags = self.tags
            self.tableView.reloadData()
            self.setupTextField()
            completion?()
        }
    }
    
    private func getTags(_ completion: @escaping (([CULTag])->Void)) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([])
            return
        }
        
        let store = Firestore.firestore()
        store.collection("users/\(currentUser.uid)/tags").getDocuments { (snapshot, error) in
            var tags: [CULTag] = []
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                for document in snapshot.documents {
                    let tag = self.tag(from: document.data(), id: document.documentID)
                    tags.append(tag)
                }
            }
            completion(tags)
        }
    }
    
    private func tag(from rawTag: [String:Any], id: String) -> CULTag {
        var tag = CULTag()
        if let name: String = rawTag["name"] as? String {
            tag.name = name
        }
        tag.identifier = id
        return tag
    }
    
    func set(contact: CULContact) {
        self.contact = contact
        self.selectedTag = nil
        self.tableView.reloadData()
    }
    
    func add(tag name: String, completion: @escaping ((CULTag?)->Void)) {
        
        var identifier: String? = "\(Date.timeIntervalSinceReferenceDate)"
        identifier = identifier?.components(separatedBy: ".").first ?? "someUniqueId"
        
        let tag: CULTag = CULTag(identifier: identifier, name: name)
        
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        
        let store: Firestore = Firestore.firestore()
        let data: [String:Any] = [
            "name": tag.name
        ]
        
        if let identifier = identifier {
            store.collection("users").document(currentUser.uid).collection("tags").document(identifier).setData(data) { (error) in
                
                if let error = error {
                    print(error)
                } else {
                    print("Success")
                    completion(tag)
                    self.loadAllAvailableTags()
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredTags.count == 0,
            self.searchText.isEmpty == false {
            
            return 1
        }
        return self.filteredTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.shouldUseCustomCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TagPickerTblCell
            if self.filteredTags.count == 0,
                self.searchText.isEmpty == false {
                
                cell.titleLabel.text = "Tap to create a new tag"
                cell.titleLabel.font = UIFont.italicSystemFont(ofSize: 17)
                cell.checkmarkImageView.isHidden = true
            } else {
                let tag = self.filteredTags[indexPath.item]
                cell.set(tag: tag, isSelected: (self.selectedTag?.identifier == tag.identifier))
            }
            return cell
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 0.3803921569, green: 0.368627451, blue: 0.3843137255, alpha: 1)
        
        if self.filteredTags.count == 0,
            self.searchText.isEmpty == false {
            
            cell.textLabel?.text = "Tap to create a new tag"
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17)
        } else {
            let tag: CULTag? = self.filteredTags[indexPath.item]
            cell.textLabel?.text = tag?.name ?? "N.A"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            
            cell.accessoryType = UITableViewCellAccessoryType.none
            if self.contact?.tag?.identifier == tag?.identifier ||
                self.selectedTag?.identifier == tag?.identifier {
                if self.shouldShowSelection {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filteredTags.count == 0,
            self.searchText.isEmpty == false {
            
            self.add(tag: self.searchText, completion: { (tag) in
                if let tag = tag {
                    self.selectedTag = tag
                    self.delegate?.selected(tag: tag, for: self.contact)
                }
            })
        } else {
            
            // Call delegate method
            let tag = self.filteredTags[indexPath.item]
            if self.selectedTag?.identifier == tag.identifier {
                self.selectedTag = nil
            } else {
                self.selectedTag = tag
            }
            self.delegate?.selected(tag: self.selectedTag, for: self.contact)
        }
        
        tableView.reloadData()
    }
}
