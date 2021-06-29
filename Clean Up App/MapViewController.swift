//
//  MapViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/25/21.
//

import MapKit
import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    
    let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    let submittedlatitudes = [45.5190, 45.5200, 45.5300]
    let submittedlongitudes = [-122.6793, -122.6000, -122.5000]
    let submittedsize = ["Small","Big", "Medium"]
    let submitteddate = ["Jun 28 | 5:43 pm","July 16 | 2:15 am", "April 4 | 6:40 am"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        
        trashmarker()

        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Uses last known location of user
        if let location = locations.last {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    func render(_ location: CLLocation){//render in location
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) //sets coordinates as user location
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) //sets how much off the map is shown from the user's location
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
    }

    var x = 0
    func trashmarker() { //function to create markers for every place trash is reported
        for trashlat in submittedlatitudes {
            let trashlong = submittedlongitudes[x]
            let trashsize = submittedsize[x]
            let trashdate = submitteddate[x]
            let trashmarker = MKPointAnnotation()
            trashmarker.coordinate = CLLocationCoordinate2D(latitude: trashlat, longitude: trashlong)
            trashmarker.title = "Size:" + trashsize + "\n Data/Time:" + trashdate
            mapView.addAnnotation(trashmarker)
            x += 1
                    }
                }
    
}
