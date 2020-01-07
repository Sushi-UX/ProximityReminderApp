//
//  SetLocationViewController.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData


class SetLocationViewController: UIViewController {
    
    //MARK: - Properties
    lazy var locationTableView: LocationTableView = {
        return LocationTableView(setLocationVC: self)
    }()
    
    //Map Properties
    let locationManager:CLLocationManager = LocationManger.sharedInstance.locationManager
    let regionInMeters: Double = 100
    var previousLocation: CLLocation?
    
    var reminderLocation: CLLocation?
    
    var mapItems: [MKMapItem] = [] {
        didSet {
            self.tableView.reloadData()
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
    
    //Callback for saving new location
    var onSave: ((_ location: (locationString: String, location: CLLocation, circle: MKCircle)) -> ())?
    
    
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Location", style: .plain, target: self, action: #selector(saveTapped))
        
        
        self.tableView.dataSource = self.locationTableView
        self.tableView.delegate = self.locationTableView
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.searchBar.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkLocationServices()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    @objc func saveTapped(sender: UITapGestureRecognizer) {
        guard let location = addressLabel.text else { return }
        guard let coordinates = self.reminderLocation else { return }
        let circle = MKCircle(center: coordinates.coordinate, radius: 30)
        let object: (locationString: String, location: CLLocation, circle: MKCircle) = (location, coordinates, circle)
        self.onSave?(object)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


//MARK: - SearchBarDelegate
extension SetLocationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = self.searchBar.text {
            if !searchString.isEmpty {
                self.populateNearByPlaces(searchString: searchString)
            } else {
                self.mapItems.removeAll()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            self.populateNearByPlaces(searchString: searchText)
        } else {
            self.mapItems.removeAll()
        }
    }
    
    
}


//MARK: - Handle Search
extension SetLocationViewController {
    
    func populateNearByPlaces(searchString: String) {
        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchString
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {
                return
            }
            
            self.mapItems = response.mapItems
            
            
            
        }
    }
    
}
