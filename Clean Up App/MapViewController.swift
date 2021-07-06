//
//  MapViewController.swift
//  Clean Up App
//
// Make edge transparent to allow swiping (or something)
// Implement RightCalloutAccesoryView
// Optional - Add search by address
//  Created by Aneesh Pandoh on 6/25/21.
//

import MapKit
import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    let submittedlatitudes = [45.5190, 45.5200, 45.5300]
    let submittedlongitudes = [-122.6793, -122.6000, -122.5000]
    let submittedsize = ["Small","Large", "Medium"]
    let submitteddate = ["Jun 28  5:43 pm","July 16  2:15 am", "April 4  6:40 am"]
    let submittedurl = ["Garbage1", "Garbage2", "Garbage3"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        manager.delegate = self
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        
        trashpin()

        
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
    func trashpin() { //function to create markers for every place trash is reported
        for trashlat in submittedlatitudes {
            let trashlong = submittedlongitudes[x]
            let trashsize = submittedsize[x]
            let trashdate = submitteddate[x]
            let trashimg = submittedurl[x]
            let trashmarker = Trashmarkers(title: trashsize + " Trash", subtitle: "Date/Time: " + trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat, longitude: trashlong), url: trashimg)
            mapView.addAnnotation(trashmarker)
            //Include array with photos set to own variables
            x += 1
                    }
                }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //Custom Trash Icons and dequeueing to become more efficient
        guard !(annotation is MKUserLocation) else { //keeps user location normal icon
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")//Dequeueing

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        annotationView?.image = UIImage(named:"Trash_Icon") //Custom Icon
        annotationView?.canShowCallout = true //shows title and subtitle field when clicked
        
        //imageviewbutton
        let imgbutton = UIButton(type: .custom)
        imgbutton.backgroundColor = .systemGreen
        imgbutton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        imgbutton.layer.cornerRadius = 0.25 * imgbutton.bounds.size.width
        imgbutton.clipsToBounds = true
        imgbutton.setImage(UIImage(named: "Photo_Icon"), for: .normal)
        
        annotationView?.rightCalloutAccessoryView = imgbutton //Button is on the right side of the clickable marker annotation field
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let trash = view.annotation as? Trashmarkers else {return}
        
        let pinUrl = trash.url //show actual trash image
        print(pinUrl)
        
        //@IBOutlet var imageView: UIImageView
    }
}
