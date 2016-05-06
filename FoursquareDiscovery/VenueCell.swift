//
//  VenueCell.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 30/04/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit

class VenueCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    let layout = UICollectionViewFlowLayout()
    
    var photoList: NSArray = [""]
    var venue: Venue?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusLabel.layer.cornerRadius = 2
        self.statusLabel.clipsToBounds = true
        
        self.collectionView.layer.cornerRadius = 2
        self.collectionView.clipsToBounds = true
        self.collectionView.pagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    func initWithVenue(venue: Venue) {
        
        self.venue = venue
        
        self.nameLabel.text = venue.name
        
        if (venue.isOpen == true) {
            self.statusLabel.text = "OPEN"
            self.statusLabel.backgroundColor = UIColor(red: 0, green: 230/255, blue: 118/255, alpha: 1)
        } else {
            self.statusLabel.text = "CLOSED"
            self.statusLabel.backgroundColor = UIColor(red: 221/255, green: 44/255, blue: 0, alpha: 1)
        }
        
        if (venue.tips != nil) {
            self.descriptionLabel.text = venue.tips[0] as? String
        }
        
        // Fetching images url
        APIManager.sharedInstance.fetchImages(venue) { (success, error, photoList) in
            if success {
                self.photoList = photoList
                self.collectionView.reloadData()
            } 
        }
    }
    
    override func layoutSubviews() {
        
        let viewsDictionary = [ "collectionView": collectionView,
                                "nameLabel": nameLabel,
                                "descriptionLabel": descriptionLabel,
                                "statusLabel": statusLabel ]
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let collectionViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[collectionView]-|",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(collectionViewVerticalConstraints);
        
        let collectionViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[collectionView]-|",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(collectionViewHorizontalConstraints);
        
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionLabelVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[descriptionLabel]-16-|",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(descriptionLabelVerticalConstraints);
        
        let descriptionLabelHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[descriptionLabel]-16-|",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(descriptionLabelHorizontalConstraints);
        
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let nameLabelVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[nameLabel][descriptionLabel]",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(nameLabelVerticalConstraints);
        
        let nameLabelHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[nameLabel]-16-|",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        self.contentView.addConstraints(nameLabelHorizontalConstraints);
        
        layout.itemSize = self.collectionView.frame.size;
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumLineSpacing = 0
        layout.collectionViewContentSize()
        self.collectionView.collectionViewLayout = layout
    }
    
    // MARK: - CollectionView delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.photoList.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCollectionViewCell", forIndexPath: indexPath) as! GalleryCollectionViewCell
        
        cell.venueImageView.image = nil
        cell.spinner.startAnimating()
        cell.spinner.hidden = false
        
        // Assign venue image as first picture and users images to the gallery
        if indexPath.row == 0 {
            if self.venue?.images!.count > 0 {
                cell.initWithImage(self.venue?.images![0] as! NSURL)
            } else {
                print("VENUE CELL ERROR: feature image not found")
            }
        } else {
            if photoList.count > 1 {
                if let image = self.photoList[indexPath.row] as? NSURL {
                    cell.initWithImage(image)
                } else {
                    print("VENUE CELL ERROR: photo list image not found")
                }
            }
        }
        
        // Updating content offset to achieve parallax effect while scrolling the gallery
        cell.parallaxImageViewScrollOffset(self.collectionView.contentOffset, scrollDirection: self.layout.scrollDirection)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.collectionView.frame.size
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Parallax visible cells
        for cell: GalleryCollectionViewCell in collectionView.visibleCells() as! [GalleryCollectionViewCell] {
            cell.parallaxImageViewScrollOffset(self.collectionView.contentOffset, scrollDirection: self.layout.scrollDirection)
        }
    }
}
