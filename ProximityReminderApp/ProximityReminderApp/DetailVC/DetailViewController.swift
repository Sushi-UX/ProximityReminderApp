//
//  DetailViewController.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class DetailViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var detailItem: Reminder? {
        didSet {
            // Update the view.
            updateView()
            self.locationPoint = self.detailItem?.locationPoint
            self.geofenceCircle = self.detailItem?.geofenceCircle
        }
    }
    let locationManager: CLLocationManager = LocationManger.sharedInstance.locationManager
    let regionInMeters: Double = 1000
    var locationPoint: CLLocation? {
        didSet {
            self.centerViewOnSelectedLocation()
        }
    }
    var geofenceCircle: MKCircle? {
        didSet {
            guard let circle = self.geofenceCircle else { return }
            self.addRadiusOverlay(forCircle: circle)
        }
    }
    var onEntry: Bool = true
    
    

//    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var locationStack: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    


    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationGesture = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
        locationStack.addGestureRecognizer(locationGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkLocationServices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetLocationSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
            
            let destinationVC = segue.destination as! SetLocationViewController
            destinationVC.reminderLocation = self.locationPoint
            
            destinationVC.onSave = { (location) in
                self.locationLabel.text = location.locationString
                self.locationPoint = location.location
                self.geofenceCircle = location.circle
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: - Methods
    @objc func locationTapped(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "SetLocationSegue", sender: nil)
    }

    func updateView() {
        // Update the user interface for the detail item.
        loadViewIfNeeded()
        if let detail = detailItem {
            self.locationLabel.text = detail.address
            self.locationPoint = detail.locationPoint
            self.titleTextField.text = detail.title
            self.messageTextField.text = detail.message
            if detail.onEntry {
                self.segmentedControl.selectedSegmentIndex = 0
            } else {
                self.segmentedControl.selectedSegmentIndex = 1
            }
            self.onEntry = detail.onEntry
        } else {
            //Set to empty view to create new Reminder
            self.titleTextField.text = nil
            self.messageTextField.text = nil
            self.removeRadiusOverlay()
            self.locationLabel.text = "Tap here to set location"
            self.locationPoint = nil
            self.geofenceCircle = nil
            self.segmentedControl.selectedSegmentIndex = 0
            self.onEntry = true
        }
    }
    
    //Handle switching segmentedControl
    func setOnEntering() {
        switch segmentedControl.selectedSegmentIndex {
            case 0: self.onEntry = true
            case 1: self.onEntry = false
            default: return
        }
    }
    
    //Save the Reminder
    func saveReminder() {
        //Check that all required fields have been filled
        guard let title = self.titleTextField.text, !title.isEmpty else { self.generalAlert(title: "Missing Title", message: "A title for this reminder is required."); return }
        guard let location = self.locationPoint else { self.generalAlert(title: "Missing Location", message: "A location for this reminder is required."); return }
        guard let address = self.locationLabel.text else { return }
        let message = self.messageTextField.text ?? nil
        
        //Check if monitored regions greater than 20
        if self.locationManager.monitoredRegions.count == 20 {
            self.generalAlert(title: "Max Reminders Reached!", message: "The App cannot monitor more than 20 regions at this time. Please delete at least one reminder before you add a new one.")
            return
        }
        
        if self.detailItem != nil {
            if self.detailItem?.locationPoint != location {
                self.locationManager.stopMonitoring(for: (detailItem?.geofenceCircularRegion)!)
            }
            self.detailItem?.title = title
            self.detailItem?.message = message
            self.detailItem?.address = address
            self.detailItem?.latitude = location.coordinate.latitude
            self.detailItem?.longitude = location.coordinate.longitude
            self.detailItem?.onEntry = self.onEntry
            
            
            locationManager.startMonitoring(for: (detailItem?.geofenceCircularRegion)!)
        } else {
            let reminder = Reminder.with(identifier: NSUUID().uuidString, onEntry: self.onEntry, title: title, message: message, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, address: address, in: self.managedObjectContext)
            
            locationManager.startMonitoring(for: reminder.geofenceCircularRegion!)
        }
        
        
        //Save changes to CoreData
        self.managedObjectContext.saveChanges()
        
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK: - Actions
    @IBAction func segmentChanged(_ sender: Any) {
        self.setOnEntering()
    }
    
    @IBAction func save(_ sender: Any) {
        self.saveReminder()
    }
    

}



//MARK: - ReminderSelectionDelegate
extension DetailViewController: ReminderSelectionDelegate {
    func reminderSelected(_ newReminder: Reminder?, with context: NSManagedObjectContext) {
        self.detailItem = newReminder
        self.managedObjectContext = context
    }
    
}
