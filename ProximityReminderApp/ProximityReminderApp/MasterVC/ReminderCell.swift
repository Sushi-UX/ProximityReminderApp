//
//  ReminderCell.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import UIKit


class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    func configure(with reminder: Reminder) {
        self.tintColor = .white
        self.titleLabel.text = reminder.title
        self.locationLabel.text = "\(reminder.address)"
    }
}

