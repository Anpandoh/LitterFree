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
import SwiftUI
import FirebaseStorage
let storage = Storage.storage()


protocol addedToCartDelegate {
    func didAddToCart()
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    
    @IBOutlet var mapView: MKMapView!
    public let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    
    //Floating cart button
    let cartButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        Utilities.styleFloatingButton(button: button)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        //cartButton
        
        view.addSubview(cartButton)
        cartButton.addTarget(self, action: #selector(didTapCartButton), for: .touchUpInside)
        
        //trashpin()//change to view did appear
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        trashpin()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cartButton.frame = CGRect(x: view.frame.size.width - 100, y: 75, width: 60, height: 60)
    }
    
    @objc private func didTapCartButton(){
        let trashCartView = TrashCartView()
        let hostingController = UIHostingController(rootView: trashCartView)
        self.present(hostingController, animated: true)
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
        let coordinate = location.coordinate//sets coordinates as user location
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
                    let trashmarker = Trashmarkers(title: "Date: " + trashdate, subtitle: trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat as! CLLocationDegrees, longitude: trashlong as! CLLocationDegrees), img: url, firebaseQuery: child)
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
        
        guard (annotation is Trashmarkers) else {
            return nil
        }
        let test = annotation as! Trashmarkers
        
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")//Dequeueing
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        annotationView?.image = UIImage(named:"Trash_Icon") //Custom Icon
        annotationView?.canShowCallout = true //shows title and subtitle field when clicked
        
        
        //imageviewbutton
        let addPinToCart = UIButton(type: .custom)

        Utilities.styleAddPinToCartButton(addPinToCart)
        
        
        annotationView?.leftCalloutAccessoryView = addPinToCart //Button is on the right side of the clickable marker annotation field
        
            
//        guard (test.inCart == false) else {
//            return nil
////            annotationView?.image = UIImage(systemName: "hand.thumbsup.circle.fill") //Dequeueing
////            return annotationView
//        }
        
        //self.configureDetailView(annotationView: annotationView!)
        
        
        return annotationView
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // initialize your custom view
        let customCalloutView = CustomCallout(frame: CGRect(x: 0, y: 0, width: 500, height: 500), annotationView: view)
        view.detailCalloutAccessoryView = customCalloutView
    }
    
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        // initialize your custom view
//        let trash = view.annotation as! Trashmarkers
//        if (trash.inCart == true) {
//            view.image = nil
//            print("Hello")
//            view.image = UIImage(systemName: "hand.thumbsup.circle.fill")
//            }
//    }
    
    func removeAnnotation(_ annotation: MKAnnotation) {
        
    }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Display trash image on seperate view controller
        
        
        
        
        let trash = view.annotation as! Trashmarkers
        trash.inCart = true
        
        view.tintColor = .systemGreen
        
        
        
        let cleanUpController = CleanUpViewController(trashCleaned: trash)
        
        let navVC = UINavigationController(rootViewController: cleanUpController)
        navVC.modalPresentationStyle = .fullScreen
        

        //snapViewer.modalTransitionStyle = .crossDissolve
        
        
        present(navVC, animated: false)
        
        
        
        //self.present(popupvc, animated:true)
        
        
        // markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "ferry_building"))
        
        
    }
}



class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}


