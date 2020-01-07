//
//  DetailMapViewDelegate.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import UIKit
import MapKit



//MapView Delegate
extension DetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    //Add overlay for geofence
    func addRadiusOverlay(forCircle circle: MKCircle) {
        loadViewIfNeeded()
        self.removeRadiusOverlay()
        self.mapView.addOverlay(circle)
    }
    
    //Remove overlay
    func removeRadiusOverlay() {
        let overlays = mapView.overlays
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            mapView.removeOverlay(circleOverlay)
        }
    }
}

//CLLocation Delegate
extension DetailViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


//MapView Methods
extension DetailViewController {
    
    func centerViewOnSelectedLocation() {
        //Check if location already set
        if let location = self.locationPoint {
            self.locationIcon.alpha = 1.0
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        } else {
            //Location point doesn't exist so set general location from higher altitude
            self.locationIcon.alpha = 0.0
            self.mapView.region = MKCoordinateRegion(center: self.locationManager.location?.coordinate ?? self.mapView.centerCoordinate, latitudinalMeters: 20000, longitudinalMeters: 20000)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            self.generalAlert(title: "Location Services is Off", message: "Please turn on location services in your settings to record a location")
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
//            self.centerViewOnSelectedLocation()
            return
        case .denied:
            // Show alert instructing them how to turn on permissions
            self.generalAlert(title: "Error!", message: "Please go to settings and make sure you have enabled location services for this app.")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            self.generalAlert(title: "Error!", message: "Please go to settings and make sure you have enabled location services for this app.")
            break
        case .authorizedAlways:
            break
        default: break
        }
    }
    
    
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
