//
//  Venues.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 30/04/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit
import CoreLocation
import Haneke

// Parsing CLLocation to string
extension CLLocation {
    
    func getLocation() -> String {
        
        let lat = self.coordinate.latitude
        let lon = self.coordinate.longitude
        
        return "\(lat),\(lon)"
    }
    
}

class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    
    var venueList = [Venue]()
    
    func fetchVenues(result: (success: Bool, error: NSError?) -> Void) {
        
        // Create cache for venue response
        let cache = Cache<JSON>(name: "venues")
        
        // Create URL with parameters
        let requestUrl = venuesCreateURLWithComponents()
        
        // Using Haneke to check if the data are cached in memory or disk, otherwise it's gonna call the API
        cache.fetch(URL: requestUrl!).onSuccess { (JSON) in
            let jsonDict: NSDictionary = JSON.dictionary
            let responseData = jsonDict["response"] as! NSDictionary
            let venues = responseData["groups"]![0]["items"] as! NSArray
            
            // Parsing JSON
            self.venueList = self.parseJSONVenueList(venues)
            
            result(success: true, error: nil)
        }.onFailure { (Error) in
            result(success: false, error: Error)
        }
    }
    
    func fetchImages(venue: Venue, result: (success: Bool, error: NSError?, photoList: [NSURL]) -> Void) {
        
        var photoList: [NSURL] = []
        
        let cache = Cache<JSON>(name: "images")
        
        let requestUrl = imagesCreateURLWithComponents(venue)
        
        cache.fetch(URL: requestUrl!).onSuccess { (JSON) in
            let jsonDict: NSDictionary = JSON.dictionary
            let responseData = jsonDict["response"] as! NSDictionary
            let photos = responseData["photos"]!["items"] as! NSArray
            
            photoList = self.parseJSONPhotoList(photos)
            
            result(success: true, error: nil, photoList: photoList)
            }.onFailure { (Error) in
            result(success: false, error: Error, photoList: photoList)
        }
    }
    
    func venuesCreateURLWithComponents() -> NSURL? {
        
        // Using EXPLORE API instead of SEARCH API to return tips and photos with one single call
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "api.foursquare.com";
        urlComponents.path = "/v2/venues/explore";
        
        // add params
        let locationQuery = NSURLQueryItem(name: "ll", value: LocationManager.sharedInstance.location.getLocation())
        let sectionQuery = NSURLQueryItem(name: "section", value: "drinks")
        
        // Asking for photos
        let venuePhotosQuery = NSURLQueryItem(name: "venuePhotos", value: "1")
        
        // Asking for opening times
        let openNowQuery = NSURLQueryItem(name: "openNow", value: "1")
        let oauthTokenQuery = NSURLQueryItem(name: "oauth_token", value: "O3N22ECSJAUFNHN1YER3WX4O5SSQ5SUPWAAGSEQVTXRZH53M")
        let versionQuery = NSURLQueryItem(name: "v", value: "20160419")
        urlComponents.queryItems = [locationQuery, sectionQuery, venuePhotosQuery, openNowQuery, oauthTokenQuery, versionQuery]
        
        return urlComponents.URL
    }
    
    func imagesCreateURLWithComponents(venue: Venue) -> NSURL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "api.foursquare.com";
        urlComponents.path = "/v2/venues/\(venue.id)/photos";
        
        // add params
        let limitQuery = NSURLQueryItem(name: "limit", value: "5")
        let oauthTokenQuery = NSURLQueryItem(name: "oauth_token", value: "O3N22ECSJAUFNHN1YER3WX4O5SSQ5SUPWAAGSEQVTXRZH53M")
        let versionQuery = NSURLQueryItem(name: "v", value: "20160419")
        urlComponents.queryItems = [limitQuery, oauthTokenQuery, versionQuery]
        
        return urlComponents.URL
    }
    
    func parseJSONVenueList(nodes: NSArray) -> [Venue] {
        var array = [Venue]()
        
        for node in nodes {
            let place = Venue(json: node)
            
            array.append(place)
        }
        return array
    }
    
    func parseJSONPhotoList(nodes: NSArray) -> [NSURL] {
        var array = [NSURL]()
        
        for node in nodes {
            let width = node["width"] as! NSInteger
            let height = node["height"] as! NSInteger
            let prefix = node["prefix"] as! String
            let suffix = node["suffix"] as! String
            let photoString = prefix + "\(width)" + "x" + "\(height)" + suffix
            let photoUrl = NSURL(string: photoString)
            
            array.append(photoUrl!)
        }
        
        return array
    }
}
