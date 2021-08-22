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
import FirebaseStorage




class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    let manager = CLLocationManager() //User location turned into a constant so it can be used by defined classes further down
    var metadataIndex =  Dictionary<String,Any>()
    var metadataunwrap = [Dictionary<String,Any>]()
    var metadatatotal = [String: Any]()
    let storage = Storage.storage().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        manager.delegate = self
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
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
    
    //getting metadata
    func fetchMetadata() {
        let ref = storage.child("images/")
        let group = DispatchGroup()
        var metadatauseful = Dictionary<String,Any>()
        ref.listAll { (result, error) in
            if error != nil {
                print("Failed to List All")
            }
            result.items.forEach {item in
                group.enter()
                item.getMetadata { [self] metadata, error in
                    if error != nil {
                        print ("Failed to Retrieve Metadata")
                        //Uh-oh, an error occurred!
                    } else {
                        metadatatotal = (metadata?.dictionaryRepresentation())! //dictionary of all metadata
                        metadatauseful = metadatatotal["metadata"] as! Dictionary<String,Any> //dictionary of metadata useful to us
                        metadatauseful.updateValue(metadatatotal["name"] as! String,forKey: "Name")
                        defer {
                            group.leave()
                        }
                        metadataunwrap.append(metadatauseful)
                        
                    }
                }
            }
            group.notify(queue: .main, execute: {
                //print(self.metadataunwrap)
                self.trashpin()
            })
        }
    }
    
    var numberFormatter = NumberFormatter()
    func trashpin() { //function to create markers for every place trash is reported
        for i in self.metadataunwrap.indices {
            self.metadataIndex = self.metadataunwrap[i]
            let trashlat = numberFormatter.number(from: (self.metadataIndex["Latitude"] ?? "0.0") as! String)
            let trashdate = (self.metadataIndex["Date"] ?? "Cannot find Date") as! String
            let trashlong = numberFormatter.number(from: (self.metadataIndex["Longitude"] ?? "0.0") as! String)
            let trashname = (self.metadataIndex["Name"] ?? "Cannot find Name") as! String
            let trashmarker = Trashmarkers(title: "Trash", subtitle: "Date/Time: " + trashdate, coordinate: CLLocationCoordinate2D(latitude: trashlat as! CLLocationDegrees, longitude: trashlong as! CLLocationDegrees), img: trashname)
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
    
    let imageCache = NSCache<AnyObject, AnyObject>()//caches images for faster loadtime
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { //button to display trash image
        guard let trash = view.annotation as? Trashmarkers else {return}
        
        
        
        let pinImg = trash.img!
        let imageloader = storage.child(pinImg)
        imageloader.downloadURL(completion: {url, error in //fetches download url
            guard let url = url, error == nil else{
                return
            }
            let urlString = url.absoluteString
            if let imageFromCache = self.imageCache.object(forKey: urlString as NSString) as? UIImage {//checks for cached image
                guard let popupvc = self.storyboard?.instantiateViewController(identifier: "popup_vc") as? ImagePopUpViewController else {return}
                popupvc.image = imageFromCache
                self.present(popupvc, animated:true)
                //return //returns to leave the annotation function
                
            }
            else {
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in //downloads the image data
                guard let data = data,  error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    guard let popupvc = self.storyboard?.instantiateViewController(identifier: "popup_vc") as? ImagePopUpViewController else {return}
                    let imageToCache = UIImage(data: data)!
                    self.imageCache.setObject(imageToCache, forKey: urlString as NSString)
                    let image = imageToCache
                    popupvc.image = image
                    self.present(popupvc, animated:true)
                }
            })
            task.resume()
            }
            //print(url)
        })
        
    }
}

