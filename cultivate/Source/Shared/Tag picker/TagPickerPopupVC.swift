//
//  TagPickerPopupVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup

class TagPickerPopupVC: UIViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtAddNewTag: UITextField!
    @IBOutlet weak var textFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    
    private lazy var tagListTableViewAdapter: TagsListTableViewAdapter = TagsListTableViewAdapter()
    private var tags = [CULTag]()
    private var popupHeightConstraint: NSLayoutConstraint!
    
    var shouldShowAddNewTagTextField = false
    var tagUpdated: ((CULTag?)->Void)?
    var selectedTag: CULTag?
    var presentingVC: UIViewController!
    var popup: KLCPopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
//        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 5
    }
    
    func set(tag: CULTag?, allTags: [CULTag] = []) {
//        self.popupHeightConstraint = popup.heightAnchor.constraint(equalToConstant: 200)
//        self.popupHeightConstraint.isActive = true
        
        self.selectedTag = tag
        self.tagListTableViewAdapter.selectedTag = tag
        self.tagListTableViewAdapter.shouldUseCustomCell = true
        self.tagListTableViewAdapter.set(tableView: self.tableView)
        self.tagListTableViewAdapter.delegate = self
        if self.shouldShowAddNewTagTextField {
            self.tableView.tableHeaderView = self.headerView
            self.tagListTableViewAdapter.textField = self.txtAddNewTag
            self.tagListTableViewAdapter.setupTextField()
        }
        self.tagListTableViewAdapter.selectedTag = self.selectedTag
        if allTags.count == 0 {
            self.tagListTableViewAdapter.loadAllAvailableTags {
                self.adjustTableViewHeight()
            }
        } else {
            self.tagListTableViewAdapter.load(tags: allTags, {
                self.adjustTableViewHeight()
            })
        }
    }
    
    private func adjustTableViewHeight() {
        var height = self.tableView.rowHeight * CGFloat(self.tagListTableViewAdapter.tags.count)
        let maxHeight = 5 * self.tableView.rowHeight
        if self.shouldShowAddNewTagTextField {
            height += 44
        }
        self.tableViewHeightConstraint.constant = min(height, maxHeight)
        self.view.layoutIfNeeded()
        
        self.popup.show(with: KLCPopupLayoutCenter)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        self.tagUpdated?(self.selectedTag)
        self.popup.dismiss(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.popup.dismiss(true)
    }
    
    func viewForPopup() -> UIView {
        return self.containerView
    }
    
    func add(tag name: String, completion: @escaping ((CULTag?)->Void))  {
        self.tagListTableViewAdapter.add(tag: name, completion: completion)
    }
}

extension TagPickerPopupVC: UITextFieldDelegate {
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
//        print(self.txtAddNewTag.text ?? "N.A")
        if let text: String = self.txtAddNewTag.text {
            self.tagListTableViewAdapter.search(tag: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: Trim characters
        if let text: String = textField.text {
            if self.tagListTableViewAdapter.filteredTagsCount() == 0 {
                self.add(tag: text, completion: { (tag) in
                    if let tag = tag {
                        self.selectedTag = tag
                    }
                })
            }
        } else {
            // TODO: Show empty textfield error
        }
        return true
    }
}


extension TagPickerPopupVC: TagsListTableViewAdapterDelegate {
    func selected(tag: CULTag?, for contact: CULContact?) {
        self.selectedTag = tag
    }
    
    func tagsLoaded(_ tags: [CULTag]) {
        // TODO: Resize the tableview here
    }
}
