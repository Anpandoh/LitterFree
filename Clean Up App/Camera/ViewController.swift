//
//  ViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/24/21.
// Camera

import UIKit
import FirebaseStorage
import Photos
import PhotosUI
import AVFoundation
import FirebaseAuth
import FirebaseOAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI



class ViewController: UIViewController, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, FUIAuthDelegate {
    
    
    
    
    
    let storage = Storage.storage().reference()
    var userImages = [UIImage]()
    //let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        manager.requestWhenInUseAuthorization()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
//        manager.startUpdatingLocation()
        let map = MapViewController()
        map.manager.requestWhenInUseAuthorization() //Interprets in the info.plist (whether the user has given location permissions)
        checkCameraPermissions()
        //view.backgroundColor = .systemRed
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(uploadButton)
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(didUploadTapButton), for: .touchUpInside)
        
        //if the user is not already signed in present loginOptions viewcontroller
        if Auth.auth().currentUser == nil {
            loginScreen()
        }
        
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Uses last known location of user
//        manager.stopUpdatingLocation()
//    }
    
    //uploadButton
    let uploadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.setImage(UIImage(named: "Upload_Icon"), for: .normal)
        return button
    }()
    
    
    //UploadButton functionality
    @objc func didUploadTapButton() { //present image selection
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let uploadvc = storyboard.instantiateViewController(identifier: "uploadNav") as UINavigationController
        //collectionvc.modalPresentationStyle =  .fullScreen
        self.present(uploadvc, animated: true)
    }
    
    //Camera////////////////////////////////////////////////
    
    //Capture Session
    var session: AVCaptureSession?
    //Photo Output
    let output = AVCapturePhotoOutput()
    //Image Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    //Shutter Button
    let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 8
        button.backgroundColor = UIColor(white:0.000, alpha:0.020)
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 166)
        uploadButton.center = CGPoint(x: view.frame.size.width/5, y: view.frame.size.height - 166)
    }
    
    
    //makes sure the user has allowed to access camera
    func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {granted in //asking for camera
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera() //setting up camera
                }
            }
        case .restricted:
            break
        case .denied:
            let dialogMessage = UIAlertController(title: "Unable to Use Camera", message: "Please change access to camera in settings", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            })
            
            //Add OK button to a dialog message
            dialogMessage.addAction(ok)
            // Present Alert to
            self.present(dialogMessage, animated: true, completion: nil)
            
            
            break
        case.authorized:
            setUpCamera() // set up camera if already allowed
        @unknown default:
            break
        }
    }
    
    //setting up camera function
    func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device) //shows input feed
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output){ //displays output video
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill //resize the video
                previewLayer.session = session
                
                DispatchQueue.main.async {
                    session.startRunning()
                    self.session = session
                }
            }
            catch {
                print("problem")
            }
        }
    }
    
    
    //captures photo
    @objc func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) { //getting photooutput and displaying it
        guard let data = photo.fileDataRepresentation() else { //photofile
            return
        }
        let image = UIImage(data: data)!
        //session?.stopRunning()//makes sure video feed isnt playing while viewing photo
//        guard let snapViewer = self.storyboard?.instantiateViewController(identifier: "snapViewer") as? SnapshotViewController else {return}
        let snapViewer = SnapshotViewController(snapShotImage: image)
        let navVC = UINavigationController(rootViewController: snapViewer)
        navVC.modalPresentationStyle = .fullScreen
        
        navVC.title = "Hello"

        //snapViewer.modalTransitionStyle = .crossDissolve
        self.present(navVC, animated: false)
    }
    
    
    //Present Login////////////////////
    func loginScreen() {
        let authViewController = loginManager.loginScreen(delegate: self)
        present(authViewController, animated: true)
    }
    
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return customizedAuthViewController(authUI : authUI)
    }
}













