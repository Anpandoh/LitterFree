//
//  Trashmarkers.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/6/21.
//

import UIKit
import MapKit
class Trashmarkers: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var img: String
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, img: String){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.img = img
    }
}
