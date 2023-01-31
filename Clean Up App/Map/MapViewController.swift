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
                    let trashmarker = Trashmarkers(title: "Date: " + trashdate, subtitle: "Date/Time: " + trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat as! CLLocationDegrees, longitude: trashlong as! CLLocationDegrees), img: url)
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
        
        
//        //imageviewbutton
        let imgbutton = UIButton(type: .custom)

        Utilities.styleImgButton(imgbutton)
        
        
        annotationView?.rightCalloutAccessoryView = imgbutton //Button is on the right side of the clickable marker annotation field
        
            
        
        
        
        //CustomCallout.delegate = self
        
        
        
        //self.configureDetailView(annotationView: annotationView!)
        
        
        return annotationView
    }
    
    func configureDetailView(annotationView: MKAnnotationView) -> UIView {
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(400)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(100)]", options: [], metrics: nil, views: views))
        
        //imageviewbutton
//        let imgbutton = UIButton(type: .custom)
//        imgbutton.frame = CGRect(x: 300, y: 100, width: 50, height: 50)
//        Utilities.styleImgButton(imgbutton)
//        snapshotView.addSubview(imgbutton)
        
        
        guard let trash = annotationView.annotation as? Trashmarkers else {return snapshotView}
        
        let imageCache = ImageCache.getImageCache()
        
        if let imageFromCache = imageCache.get(forKey: trash.img!) {
            //            loadingVC.dismiss(animated: true) //Dismisses the loading screen
            
            print("Using Cache");
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//            imageView.image = imageFromCache
            let imageView = UIImageView(image: imageFromCache)
            imageView.frame = CGRect(x: snapshotView.bounds.midX, y: 100, width: 144, height: 256)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            snapshotView.addSubview(imageView)
            
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
                                imageView.frame = CGRect(x: 0, y: 0, width: 72, height: 128)
                                //annotationView.detailCalloutAccessoryView?.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
                                imageView.clipsToBounds = true
                                imageView.contentMode = .scaleAspectFit
                                imageView.backgroundColor = .systemGreen
                                snapshotView.addSubview(imageView)

                            }
                        }
                    }
                }
            }
        }
        
        
        return snapshotView
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // initialize your custom view
        let customCalloutView = CustomCallout(frame: CGRect(x: 0, y: 0, width: 500, height: 500), annotationView: view)
        view.detailCalloutAccessoryView = customCalloutView
        
        
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Display trash image on seperate view controller
        
        //        guard let popupvc = self.storyboard?.instantiateViewController(identifier: "popup_vc") as? ImagePopUpViewController else {return}
        //        popupvc.setImage(url: trash.img!)
        
        
        view.image = UIImage(systemName: "hand.thumbsup.circle.fill")
        
        view.tintColor = .systemGreen
        
        let cleanUpController = CleanUpViewController()
        cleanUpController.modalPresentationStyle = .fullScreen
        

        //snapViewer.modalTransitionStyle = .crossDissolve
        
        
        present(cleanUpController, animated: false)
        
        
        
        
        
        
        
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


