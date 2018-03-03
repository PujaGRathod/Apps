//
//  FrequencyPickerPopupVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 17/01/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import KLCPopup

class FrequencyPickerPopupVC: UIViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
    private var frequencies: [CULFollowupFrequency] = [
        .two_weeks,
        .one_month,
        .two_months,
        .three_months,
        .four_months,
        .six_months,
        .one_year
    ]
    var selectedFrequency: CULFollowupFrequency? {
        didSet {
            self.validateSubmitButton()
        }
    }
    var frequencyUpdated: ((CULFollowupFrequency)->Void)?
    var presentingVC: UIViewController!
    var popup: KLCPopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        
        self.containerView.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 5
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "FrequencyPickerTblCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
        
        self.tableView.rowHeight = 44
        self.tableViewHeightConstraint.constant = CGFloat(self.frequencies.count) * self.tableView.rowHeight
        self.containerViewWidthConstraint.constant = UIScreen.main.bounds.width - 30
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if let frequency = self.selectedFrequency {
            self.frequencyUpdated?(frequency)
            self.popup.dismiss(true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.popup.dismiss(true)
    }
    
    func viewForPopup() -> UIView {
        return self.containerView
    }
    
    func validateSubmitButton() {
        guard self.selectedFrequency != nil else {
            self.submitButton.isEnabled = false
            return
        }
    }
}

extension FrequencyPickerPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frequencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FrequencyPickerTblCell
        let frequency = self.frequencies[indexPath.item]
        cell.set(frequency: frequency, isSelected: (self.selectedFrequency == frequency))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedFrequency = self.frequencies[indexPath.item]
        self.tableView.reloadData()
    }
}
