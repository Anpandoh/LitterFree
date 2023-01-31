//
//  SelectLocationController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 10/14/22.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

class SelectLocationController: UIViewController, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let map = MapViewController()
    var finalLoc = CLLocation()
    var db: DatabaseReference!
    private let storage = Storage.storage().reference()
    private let image: UIImage
    
    init(snapShotImage: UIImage){
        self.image = snapShotImage
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userLocation = map.manager.location
        setupMap(userLocation: userLocation!)
        finalLoc = userLocation!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(didTapSubmitButton))
        
        navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        navigationItem.backBarButtonItem?.tintColor = .systemGreen
        
    }
    
    
    @objc func didTapSubmitButton() {
        print(finalLoc)
        
        
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        
        let latitude = String(finalLoc.coordinate.latitude )
        let longitude = String(finalLoc.coordinate.longitude )
        
        
        let imguploadtime = formatter.string(from: now)
        var trashDict = [
            "Latitude":latitude,
            "Longitude":longitude,
            "Date":imguploadtime
        ]
        
        
        
        let Metadata = StorageMetadata()
        Metadata.contentType = "images/jpeg" //FIREBASE IS BROKEN AND WILL ONLY ALLOW CUSTOM METADATA IF CONTENTTYPE AND OTHERS REMAIN UNSPECIFIED
        //Metadata.customMetadata = metadataDict;
        
        //SampleUserName
        let userID = Auth.auth().currentUser?.uid
        
        let imageData = image.jpegData(compressionQuality: 0.8)!
        
        //uploadimagedata
        let ref = storage.child("images/" + imguploadtime + " " + userID!)
        self.db = Database.database().reference()
        
        ref.putData(imageData, metadata: Metadata, completion: { _, error in
            guard error == nil else {
                print("Failed to Upload")
                return
            }
            self.storage.child("images/" + imguploadtime + " " + userID!).downloadURL(completion:{url, error in //gets download URL
                guard let url = url, error == nil else {return}
                let urlString = url.absoluteString
                trashDict["url"] = urlString
                self.db.child("TrashInfo").child(LocationHelp.closestUserCity(UserLocation: self.map.manager.location!).name).child(userID!).child(imguploadtime).setValue(trashDict)
                
                //metadataDict.add
                print("Image URL:" + urlString)
            })
        })
        //addpoints
        let test = userPoints()
        do {
            try test.addPoints(NumberOfPoints: Constants.POINTVALUES.trashAdded)
        } catch {
            print("fail")
        }
        
        dismiss(animated: false)
        
        
    }
    
    
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.text =  "Hold then Drag to Adjust Pin"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.label
        label.textColor = .systemBackground
        label.alpha = 0.5
        return label
    } ()
    
    //Sets up map at right location, zoom and adds compass
    
    func setupMap(userLocation location: CLLocation) {
        view.addSubview(mapView)
        mapView.frame = view.bounds
//        mapView.isScrollEnabled = false
//        mapView.isZoomEnabled = false
//        mapView.isZoomEnabled = false
        mapView.delegate = self
        
        self.mapView.showsCompass = false
        let compass = MKCompassButton(mapView:self.mapView)
        compass.frame.origin = CGPoint(x: view.bounds.maxX - 50,y: view.bounds.maxY - 100)
        compass.compassVisibility = .visible
        self.view.addSubview(compass)
        
        showCircle(coordinate: location.coordinate,
                   radius: location.horizontalAccuracy)
        
        render(location)
        addTrashPin(AddCLLocation: location)
        
        view.addSubview(informationLabel)
        informationLabel.frame = CGRect(x: Int(view.frame.size.width)/4, y: 100, width: Int(view.frame.maxX)/2, height: 100)
    }
    
    
    
    
    //Renders in Map
    func render(_ location: CLLocation){//render in location
        let coordinate = location.coordinate //sets coordinates as user location
        let span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005) //sets how much off the map is shown from the user's location
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
    }
    
    
    
    
    //adds circle of in accuracy
    func showCircle(coordinate: CLLocationCoordinate2D,
                    radius: CLLocationDistance) {
        let circle = MKCircle(center: coordinate,
                              radius: radius)
        
        //set drag state to stop if outside of MKCircle
        
        mapView.addOverlay(circle)
    }
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // If you want to include other shapes, then this check is needed.
        //            if let circleOverlay = overlay as? MKCircle {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = .systemMint
        circleRenderer.alpha = 0.1
        
        return circleRenderer
        //}
        
        //            // If other shapes are required, handle them here
        //            return <#Another overlay type#>
    }
    
    
    
    
    
    
    //Adds trashpin, making sure it is draggable
    func addTrashPin(AddCLLocation location: CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        pin.title = "hi"
        mapView.addAnnotation(pin)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        
        let reuseId = "pin"
        
        //Deprecated but better than MKMarkerAnnotationView
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //pinView!.canShowCallout = true
            pinView!.isDraggable = true
            //pinView!.annotation!.coordinate
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .systemGreen
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
        
        
        //        guard !(annotation is MKUserLocation) else { //keeps user location normal icon
        //            return nil
        //        }
        //        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PinView")//Dequeueing
        //        //
        //        if annotationView == nil {
        //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
        //        } else {
        //            annotationView?.annotation = annotation
        //        }
        //        annotationView?.image = UIImage(named:"SingleTrash_Icon") //Custom Icon
        //        annotationView?.isDraggable = true
        //        //annotationView?.canShowCallout = true
        //
        //
        //
        //
        //
        //
        //        return annotationView
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if newState == MKAnnotationView.DragState.ending {
            let ann = view.annotation
            finalLoc = CLLocation(latitude: ann!.coordinate.latitude, longitude: ann!.coordinate.longitude)
            print("annotation dropped at: \(ann!.coordinate.latitude),\(ann!.coordinate.longitude)")
        }
    }
    
    
    
    //    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
    //        switch newState {
    //        case .starting:
    //            view.dragState = .dragging
    //        case .ending:
    //            print(view.annotation?.coordinate.latitude)
    //            print(view.annotation?.coordinate.longitude)
    //            view.dragState = .none
    //
    //        case .canceling:
    //            view.dragState = .none
    //        default: break
    //        }
    //    }
    
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //        view.image = UIImage(named: "SingleTrash_Icon")
    //    }
    
    
    
    
    
    
    
    //Setup Map
    
    
    //Get user location and put annotation there
    
    
    //Create circle around CLLocation.horizontalAccuracy
    
    //Only allow taps within circle
    
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
