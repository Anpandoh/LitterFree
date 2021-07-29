//
//  MapViewController.swift
//  Clean Up App
//
// Make edge transparent to allow swiping (or something)
// Implement RightCalloutAccesoryView
// Optional - Add search by address
// Optional bind to only coordinates inside Portland
// 
//  Created by Aneesh Pandoh on 6/25/21.
//

import MapKit
import UIKit
import FirebaseStorage


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    var numberFormatter = NumberFormatter()
    var metadataIndex =  NSDictionary()
    var metadataunwrap = [NSDictionary]()
    private var metadataTotal = [String: Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        manager.delegate = self
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        fetchMetadata()

        
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
    
    //getting metadata
    func fetchMetadata() {
        let storage = Storage.storage().reference()
        let ref = storage.child("images/")
        let group = DispatchGroup()
        ref.listAll { (result, error) in
            if let error = error {
                print("Failed to ListALL")
            }
            result.items.forEach {item in
                group.enter()
                item.getMetadata { [self] metadata, error in
                    if let error = error {
                        print ("Failed to Retrieve Metadata")
                        //Uh-oh, an error occurred!
                    } else {
                        metadataTotal = (metadata?.dictionaryRepresentation())!
                        //print(self.metadatavar)
                        
                        //metadatavar["metadata"].append(or equivlaent function for NSDictionary) and add the download URL
//                   item.downloadURL { url, error in
//                   if let error = error {
                            //print ("Fauked to Retrieved Download URL")
//                            // Handle any errors
//                       else {
//                            // Get the download URL for
//                       }
//                     }
//
                        
                        
                        
                        defer {
                            group.leave()
                        }
                        metadataunwrap.append(metadataTotal["metadata"] as! NSDictionary)

                        
                    }
                }
            }
            group.notify(queue: .main, execute: {
                self.trashpin()
            })
        }
    }
    
    func trashpin() { //function to create markers for every place trash is reported
        for i in self.metadataunwrap.indices {
            self.metadataIndex = self.metadataunwrap[i]
            let trashlat = numberFormatter.number(from: (self.metadataIndex["Latitude"] ?? "Cannot find Latitude") as! String)
            let trashdate = (self.metadataIndex["Date"] ?? "Cannot find Date") as! String
            let trashlong = numberFormatter.number(from: (self.metadataIndex["Longitude"] ?? "Cannot find Longitude") as! String)
            let trashmarker = Trashmarkers(title: "Trash", subtitle: "Date/Time: " + trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat as! CLLocationDegrees, longitude: trashlong as! CLLocationDegrees), img: "hi")
            mapView.addAnnotation(trashmarker)
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
        
        let pinImg = trash.img //show actual trash image
        print(pinImg)
        //@IBOutlet var imageView: UIImageView
    }
}
