//
//  Venue.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 30/04/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit

class Venue: NSObject {
    
    var name: String!
    var id: String!
    var isOpen: Bool!
    var images: NSArray?
    var tips: NSArray!
    
    init(json: AnyObject) {
        super.init()
        
        if let venue = json["venue"] as? NSDictionary {
            
            if let name = venue["name"] {
                self.name = name as! String
            } else {
                print("ERROR: name")
            }
            
            if let id = venue["id"] {
                self.id = id as! String
            } else {
                print("ERROR: id")
            }
            
            if let openingHours = venue["hours"] {
                if let isOpen = openingHours["isOpen"] {
                    self.isOpen = isOpen as! Bool
                } else {
                    self.isOpen = false
                    print("ERROR: isOpen")
                }
            } else {
                self.isOpen = false
                print("ERROR: hours")
            }
            
            if let imageDic = venue["featuredPhotos"] {
                if let images = imageDic["items"] as? NSArray {
                    self.images = parseJSONPhotos(images)
                } else {
                    print("ERROR: images")
                    self.images = []
                }
            } else {
                print("ERROR: imageDic")
                self.images = []
            }
        }
        
        if let tips = json["tips"] as? NSArray {
            self.tips = parseJSONTips(tips)
        } else {
            print("ERROR: tips")
        }
    }
    
    func parseJSONPhotos(nodes: NSArray) -> [NSURL] {
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
    
    func parseJSONTips(nodes: NSArray) -> [String] {
        var array = [String]()

        for node in nodes {
            if let description = node["text"] as? String {
                array.append(description)
            } else {
                print("ERROR: tips parser")
            }
        }
        
        return array
    }
}
