//
//  CustomCallout.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 1/23/23.
//

import UIKit
import MapKit

class CustomCallout: UIView {
    
    
    let CALLOUTWIDTH = 270
    let CALLOUTHEIGHT = 480

    
    init(frame: CGRect, annotationView: MKAnnotationView) {
        // setup constraints for custom view
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: CGFloat(CALLOUTWIDTH)),
            heightAnchor.constraint(equalToConstant: CGFloat(CALLOUTHEIGHT))
        ])
        
        
        
        
        
        guard let trash = annotationView.annotation as? Trashmarkers else {return}
        
        let imageCache = ImageCache.getImageCache()
        
        if let imageFromCache = imageCache.get(forKey: trash.img!) {
            //            loadingVC.dismiss(animated: true) //Dismisses the loading screen
            
            print("Using Cache");
            //            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            //            imageView.image = imageFromCache
            let imageView = UIImageView(image: imageFromCache)
            imageView.frame = CGRect(x: 0, y: 0, width: CGFloat(CALLOUTWIDTH), height: CGFloat(CALLOUTHEIGHT))
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            
        }//checks for cached image
        
        //If nothing in cache
        else {
            print("Not using Cache");
            
            //let url = URL(string: urlLink)!
            
            let httpsReference = storage.reference(forURL: trash.img!)
            
            DispatchQueue.global().async {
                httpsReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        DispatchQueue.main.async {
                            // Data for url is returned
                            if let imageToCache = UIImage(data: data!)  {
                                imageCache.set(forKey: trash.img!, image: imageToCache)
                                let imageView = UIImageView(image: imageToCache)
                                //let imageView = UIImageView(image: UIImage(named: "sun.max"))
                                imageView.frame = CGRect(x: 0, y: 0, width: CGFloat(self.CALLOUTWIDTH), height: CGFloat(self.CALLOUTHEIGHT))
                                //annotationView.detailCalloutAccessoryView?.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
                                imageView.clipsToBounds = true
                                imageView.contentMode = .scaleAspectFit
                                imageView.backgroundColor = .systemGreen
                                self.addSubview(imageView)
                                
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
