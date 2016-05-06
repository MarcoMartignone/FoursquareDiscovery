//
//  ViewController.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 30/04/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit
import CoreLocation
import Haneke

class VenueViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        // Checking for location permissions
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0)
        
        // Adding pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        
        // Load venues
        self.refresh()
    }

    // MARK: - CoreLocation delegates
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty {
            return
        }
        
        // Assign latest location to LocationManager singleton
        LocationManager.sharedInstance.location = locations.last!
    }
    
    func refresh() {
        APIManager.sharedInstance.fetchVenues { (success, error) in
            if success {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            } else {
                print(error);
            }
        }
    }
    
    // MARK: - TableView delegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return APIManager.sharedInstance.venueList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell") as! VenueCell
        
        let venue = APIManager.sharedInstance.venueList[indexPath.row]
        
        // Reset CollectionView offset in VenueCell
        cell.collectionView.setContentOffset(CGPointZero, animated: false)
        
        // Init cell with venue model
        cell.initWithVenue(venue)
        
        return cell
    }
}

