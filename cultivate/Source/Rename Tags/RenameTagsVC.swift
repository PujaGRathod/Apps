//
//  RenameTagsVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 23/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit

class RenameTagsVC: UIViewController {

    @IBOutlet weak var tagsTableView: UITableView!
    @IBOutlet weak var menuButton: CULHamburgerMenuBarButton!
    
    private lazy var tagListTableViewAdapter: TagsListTableViewAdapter = TagsListTableViewAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagListTableViewAdapter.shouldShowSelection = false
        self.tagListTableViewAdapter.set(tableView: self.tagsTableView)
        self.tagListTableViewAdapter.delegate = self
        
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showHUD(with: "Loading tags")
        self.tagListTableViewAdapter.loadAllAvailableTags()
        self.tagListTableViewAdapter.selectedTag = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditTag",
            let nav = segue.destination as? CULNavigationController,
            let vc = nav.viewControllers.first as? EditTagVC {
            
            vc.tag = sender as! CULTag
        }
    }
}

extension RenameTagsVC: TagsListTableViewAdapterDelegate {
    
    func tagsLoaded(_ tags: [CULTag]) {
        self.hideHUD()
    }
    
    func selected(tag: CULTag?, for contact: CULContact?) {
        self.performSegue(withIdentifier: "segueEditTag", sender: tag)
    }
}
