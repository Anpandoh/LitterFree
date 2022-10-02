//
//  LocationHelp.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 10/1/22.
//

import Foundation
import CoreLocation

class LocationHelp {
    
    struct cities {
        struct Portland {
            let name = "Portland"
            let latitude = 45.523064
            let longitude = -122.676483
        }
        struct Madison {
            let name = "Madison"
            let latitude = 43.0722
            let longitude = -89.4008
        }
    }
    
    struct closestUserCity {
        var name: String
        var latitude: Double
        var longitude: Double
        init(UserLocation: CLLocation) {
            if (UserLocation.distance(from: CLLocation(latitude:cities.Portland().latitude, longitude: cities.Portland().longitude)) >
                UserLocation.distance(from: CLLocation(latitude:cities.Madison().latitude, longitude: cities.Madison().longitude))) {
                name = cities.Madison().name
                latitude = cities.Madison().latitude
                longitude = cities.Madison().longitude
            } else {
                name = cities.Portland().name
                latitude = cities.Portland().latitude
                longitude = cities.Portland().longitude
            }
            
        }
        
    }
    
    
}
