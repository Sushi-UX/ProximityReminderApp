//
//  Reminder+CoreDataProperties.swift
//  ProximityReminderApp
//
//  Created by Raymond Choy on 1/6/20.
//  Copyright © 2020 thechoygroup. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit


@objc(Reminder)
public class Reminder: NSManagedObject {
    //Testing lazily loaded variables
    lazy var locationPointTest: CLLocation? = {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }()
}

extension Reminder {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate?) -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
        return request
    }

    @NSManaged public var address: String
    @NSManaged public var identifier: String
    @NSManaged public var message: String?
    @NSManaged public var onEntry: Bool
    @NSManaged public var title: String
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}

extension Reminder {
    static var entityName: String {
        return String(describing: Reminder.self)
    }
    
    @nonobjc class func with(identifier: String, onEntry: Bool, title: String, message: String?, latitude: Double, longitude: Double, address: String, in context: NSManagedObjectContext) -> Reminder {
        
        let reminder = NSEntityDescription.insertNewObject(forEntityName: Reminder.entityName, into: context) as! Reminder
        
        reminder.address = address
        reminder.identifier = identifier
        reminder.onEntry = onEntry
        reminder.title = title
        reminder.message = message
        reminder.latitude = latitude
        reminder.longitude = longitude
        
        
        return reminder
    }
}


//MARK: - Location Properties
extension Reminder {
    //Exact location from selected latitude/longitude
    var locationPoint: CLLocation? {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    //Geofenced overlay
    var geofenceCircle: MKCircle? {
        if let coordinate2D = locationPoint?.coordinate {
            let circle = MKCircle(center: coordinate2D, radius: 30)
            return circle
        }
        return nil
    }
    
    var geofenceCircularRegion: CLCircularRegion? {
        if let location = locationPoint {
            let region = CLCircularRegion(center: location.coordinate, radius: 30.0, identifier: self.identifier)
            region.notifyOnEntry = onEntry
            region.notifyOnExit = !onEntry
            return region
        }
        return nil
    }
    
}
