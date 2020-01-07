//
//  LocationManager.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import CoreLocation


class LocationManger: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    static let sharedInstance = LocationManger()
    
    
}
