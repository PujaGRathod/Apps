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

    private var contacts: [CULContact] = []
    
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
    }
}

extension DashboardTableViewAdapter: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title for header"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardContactTblCell", for: indexPath) as! DashboardContactTblCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28 + 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardTableViewHeader") as! DashboardTableViewHeader
        headerView.titleLabel.text = "Something like a title over here"
        return headerView
    }
}
