//
//  SetLocationMapViewDelegate.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import UIKit
import MapKit


//MapView Delegate
extension SetLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        self.reminderLocation = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 10 else { return }
        self.previousLocation = center
        
        self.reverseGeocode(with: geoCoder, for: center)
    }
    
}

//CLLocation Delegate
extension SetLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


//MapView Methods
extension SetLocationViewController {
    func centerViewOnUserLocation() {
        //Check if location already set
        if let location = self.reminderLocation {
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        } else if let location = locationManager.location {
        //If not center on current location
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            //            self.entryLocation = location
        } else {
            self.generalAlert(title: "Error!", message: "There was an error getting your location. Please check your settings and try again.")
            return
        }
        
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        self.reverseGeocode(with: geoCoder, for: center)
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            self.generalAlert(title: "Location Services Off", message: "Please turn on location services in your settings to record a location")
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                startTackingUserLocation()
            case .denied:
                // Show alert instructing them how to turn on permissions
                self.generalAlert(title: "Error!", message: "Please go to settings and make sure you have enabled location services for this app.")
                break
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted:
                // Show an alert letting them know what's up
                self.generalAlert(title: "Error!", message: "Please go to settings and make sure you have enabled location services for this app.")
                break
            case .authorizedAlways:
                startTackingUserLocation()
            default: break
        }
    }
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    func reverseGeocode(with geoCoder: CLGeocoder, for center: CLLocation) {
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                //TODO: Show alert informing the user
                self.generalAlert(title: "Error!", message: "There was an error.\n\nError: \(error.localizedDescription)")
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            self.setAddressLabel(with: placemark)
            
        }
    }
    
    func setAddressLabel(with placemark: CLPlacemark) {
        var addressString: String = ""
        
        if let buildingNumber = placemark.subThoroughfare {
            addressString = addressString + buildingNumber + " "
        }
        if let street = placemark.thoroughfare {
            addressString = addressString + street + " "
        }
        if let city = placemark.locality {
            addressString = addressString + city + ", "
        }
        if let state = placemark.administrativeArea {
            addressString = addressString + state + ", "
        }
        if let country = placemark.isoCountryCode {
            addressString = addressString + country
        }
        
        DispatchQueue.main.async {
            self.addressLabel.text = addressString
        }
        
    }

}
