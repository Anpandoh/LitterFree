//
//  Trashmarkers.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/6/21.
//

import UIKit
import MapKit
import Firebase
class Trashmarkers: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var img: String?
    var inCart: Bool
    var firebaseQuery: DataSnapshot
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, img: String, firebaseQuery: DataSnapshot){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.img = img
        self.inCart = false
        self.firebaseQuery = firebaseQuery
        
    }
}
