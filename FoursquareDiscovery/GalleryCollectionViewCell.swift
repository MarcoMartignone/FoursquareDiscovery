//
//  galleryCollectionViewCell.swift
//  FoursquareDiscovery
//
//  Created by Marco Martignone on 03/05/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.venueImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.venueImageView.layer.cornerRadius = 2
        self.venueImageView.clipsToBounds = true
    }
    
    func initWithImage(imageUrl: NSURL) {
        
        // Set image using Haneke caching system
        self.venueImageView.hnk_setImageFromURL(imageUrl, placeholder: nil, format: nil, failure: { (Error) in
            print("GalleryCollectionView ERROR: \(Error)")
            }) { (image) in
                self.spinner.stopAnimating()
                self.spinner.hidden = true
                
                self.venueImageView.image = image
        }
    }
    
    override func layoutSubviews() {
        
        // VLF causing problems with nested collectionview, so setting layout in the old (easy) way 🙃
        
        self.venueImageView.frame = self.frame
        self.layerView.frame = self.frame
        self.spinner.frame = self.frame
    }
    
    func parallaxImageViewScrollOffset(offsetPoint:CGPoint, scrollDirection:UICollectionViewScrollDirection) {
        // Horizontal? If not, it's vertical
        let isHorizontal = .Horizontal == scrollDirection
        
        // Choose the amount of parallax, one might say the distance from the viewer
        // 1 would mean the image wont move at all, 0.1 it moves a little
        let factor: CGFloat = 0.5
        let parallaxFactorX: CGFloat = isHorizontal ? factor : 0.0
        let parallaxFactorY: CGFloat = isHorizontal ? 0.0 : factor
        
        // Calculate the image position and apply the parallax factor
        let finalX = (offsetPoint.x - self.frame.origin.x) * parallaxFactorX
        let finalY = (offsetPoint.y - self.frame.origin.y) * parallaxFactorY
        
        // Now we have final position, set the offset of the frame of the backgroundiamge
        let frame = self.venueImageView.bounds
        let offsetFame = CGRectOffset(frame, CGFloat(finalX), CGFloat(finalY))
        self.venueImageView.frame = offsetFame
        self.layerView.frame = offsetFame
        self.spinner.frame = offsetFame
    }

}
