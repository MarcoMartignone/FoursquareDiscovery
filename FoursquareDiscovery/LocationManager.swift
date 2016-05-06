//
//  Location.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 30/04/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    var location: CLLocation
    var manager = CLLocationManager()
    
    override init () {
        
        if (manager.location != nil) {
            location = manager.location!
        } else {
            location = CLLocation(latitude: 51.5287718, longitude: -0.241682)
        }
    }

}
