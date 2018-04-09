//
//  NotificationSettingsVC.swift
//  cultivate
//
//  Created by Akshit Zaveri on 05/03/18.
//  Copyright © 2018 Akshit Zaveri. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationSettingsVC: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var segmentFrequency: UISegmentedControl!
    @IBOutlet weak var constraintWidthWeeklyDayPicker: NSLayoutConstraint!
    @IBOutlet weak var pickerWeeklyDays: UIPickerView!
    @IBOutlet weak var pickerDateTime: UIDatePicker!
    
    @IBOutlet weak var cellFrequency: UITableViewCell!
    @IBOutlet weak var cellPicker: UITableViewCell!
    @IBOutlet var noPermissionsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburgerMenuVC.configure(self.menuButton, view: self.view)
        
        self.pickerWeeklyDays.dataSource = self
        self.pickerWeeklyDays.delegate = self
        self.pickerWeeklyDays.selectRow(0, inComponent: 0, animated: false)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay]) {(accepted, error) in
            DispatchQueue.main.async {
                if accepted {
                    if let ns = CULFirebaseGateway.shared.loggedInUser?.notificationSettings {
                        if ns.frequency == .daily {
                            self.select(segmentIndex: 0, animated: false)
                        } else {
                            self.select(segmentIndex: 1, animated: false)
                            
                            if let index = DateFormatter().weekdaySymbols.map({ return $0.lowercased() }).index(of: ns.frequency.rawValue) {
                                self.pickerWeeklyDays.selectRow(index, inComponent: 0, animated: false)
                            }
                        }
                        
                        let df = DateFormatter()
                        df.dateFormat = "HH:mm"
                        if let date = df.date(from: ns.time) {
                            self.pickerDateTime.date = date
                        }
                    } else {
                        self.select(segmentIndex: 0, animated: false)
                    }
                } else {
                    self.cellFrequency.isHidden = true
                    self.cellPicker.isHidden = true
                    self.tableView.backgroundView = self.noPermissionsView
                }
            }
        }
    }
    
    @IBAction func segmentOptionChanged(_ sender: UISegmentedControl) {
        self.select(segmentIndex: sender.selectedSegmentIndex)
    }
    
    func select(segmentIndex: Int, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.27 : 0) {
            self.segmentFrequency.selectedSegmentIndex = segmentIndex
            if segmentIndex == 0 {
                self.constraintWidthWeeklyDayPicker.constant = 0
            } else if segmentIndex == 1 {
                self.constraintWidthWeeklyDayPicker.constant = 140
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSaveTapped(_ sender: CULButton) {
        if let user = CULFirebaseGateway.shared.loggedInUser {
            var ns = NotificationSettings()
            //            ns.frequency
            
            if self.segmentFrequency.selectedSegmentIndex == 0 {
                ns.frequency = .daily
            } else {
                let weekday = DateFormatter().weekdaySymbols[self.pickerWeeklyDays.selectedRow(inComponent: 0)]
                ns.frequency = NotificationSettings.Frequency(rawValue: weekday.lowercased()) ?? .monday
            }
            
            let date = self.pickerDateTime.date
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            ns.time = df.string(from: date)
            
            user.notificationSettings = ns
            
            CULFirebaseGateway.shared.getContacts(for: user, { (contacts) in
                CULNotificationsManager.shared.setupLocalNotifications(for: contacts)
            })
            
            self.showHUD()
            CULFirebaseGateway.shared.update(notificationSettings: ns, for: user, completion: { (error) in
                print("Notifications settings updated \(String(describing: error))")
                self.hideHUD()
                
                self.showAlert("Success", message: "Notification preferences saved.")
            })
        }
    }
    
    @IBAction func btnSettingsTapped(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
}

extension NotificationSettingsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DateFormatter().weekdaySymbols[row]
    }
}
