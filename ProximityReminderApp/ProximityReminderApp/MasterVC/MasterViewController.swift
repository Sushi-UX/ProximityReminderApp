//
//  MasterViewController.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

//Protocol for sending selected entry to DetailViewController
protocol ReminderSelectionDelegate: class {
    func reminderSelected(_ newReminder: Reminder?, with context: NSManagedObjectContext)
}

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //MARK: - Properties
    var managedObjectContext = CoreDataStack().managedObjectContext

    lazy var dataSource: MasterVCDataSource = {
        return MasterVCDataSource(tableVC: self)
    }()
    
    weak var delegate: ReminderSelectionDelegate?
    
    var locationManager = LocationManger.sharedInstance.locationManager

    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = dataSource
        self.tableView.delegate = dataSource
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - Actions
    @IBAction func createReminder(_ sender: Any) {
        self.delegate?.reminderSelected(nil, with: self.managedObjectContext)
        if let detailViewController = self.delegate as? DetailViewController,
            let detailNavigationController = detailViewController.navigationController {
            self.splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
    }


}

