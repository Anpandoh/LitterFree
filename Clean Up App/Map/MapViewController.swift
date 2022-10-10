//
//  MapViewController.swift
//  Clean Up App
//
//
//  Created by Aneesh Pandoh on 6/25/21.
//

import MapKit
import UIKit
import FirebaseAuth
import FirebaseDatabase



class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        manager.delegate = self
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        //trashpin()//change to view did appear
    }
    override func viewDidAppear(_ animated: Bool) {
        trashpin()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Uses last known location of user
        //        if let location = locations.last {
        manager.stopUpdatingLocation()
        
        let location = CLLocation(latitude: LocationHelp.closestUserCity(UserLocation: locations.last!).latitude, longitude: LocationHelp.closestUserCity(UserLocation: locations.last!).longitude)
        //let madisonLocation = CLLocation(latitude: 43.0722, longitude: -89.4008)

        render(location)
        //        }
    }
    
    
    func render(_ location: CLLocation){//render in location
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) //sets coordinates as user location
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) //sets how much off the map is shown from the user's location
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
    }
    
    
    var numberFormatter = NumberFormatter()
    var db: DatabaseReference!
    func trashpin() { //function to create markers for every place trash is reported
        
        
        //Shows loading screen while metdata is being fetched
        let loadingVC = LoadingViewController()
        
        // Animate loadingVC over the existing views on screen
        loadingVC.modalPresentationStyle = .overCurrentContext
        
        // Animate loadingVC with a fade in animation
        loadingVC.modalTransitionStyle = .crossDissolve
        
        present(loadingVC, animated: true, completion: nil)
        
        
        db = Database.database().reference()
        //Only shows the trashpins at current city location
        let trashInfo = self.db.child("TrashInfo").child(LocationHelp.closestUserCity(UserLocation: manager.location!).name)
        
        trashInfo.observeSingleEvent(of: .value) { [self] snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:[String:String]] else {
                    print("Error")
                    return
                }
                for (_, value) in dict {
                let trashlat = self.numberFormatter.number(from: (value["Latitude"] ?? "DNE") as String)
                let trashdate = (value["Date"] ?? "DNE") as String
                let trashlong = self.numberFormatter.number(from: (value["Longitude"] ?? "DNE") as String)
                let url = (value["url"] ?? "DNE") as String
                let trashmarker = Trashmarkers(title: "Trash", subtitle: "Date/Time: " + trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat as! CLLocationDegrees, longitude: trashlong as! CLLocationDegrees), img: url)
                mapView.addAnnotation(trashmarker)

                }
            }
        }
        
        loadingVC.dismiss(animated: true) //Dismisses the loading screen

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
        Utilities.styleImgButton(imgbutton)
        
        
        annotationView?.rightCalloutAccessoryView = imgbutton //Button is on the right side of the clickable marker annotation field
        
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Display trash image on seperate view controller
        guard let trash = view.annotation as? Trashmarkers else {return}
        
        guard let popupvc = self.storyboard?.instantiateViewController(identifier: "popup_vc") as? ImagePopUpViewController else {return}
        popupvc.setImage(url: trash.img!)
        self.present(popupvc, animated:true)
    }
}


