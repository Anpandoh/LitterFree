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



class ViewController: UIViewController, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
    
    
    
    
    
    
    //    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    private var userImages = [UIImage]()
    let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //Has GPS accuracy set to best
        manager.startUpdatingLocation()
        checkCameraPermissions()
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(uploadButton)
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(didUploadTapButton), for: .touchUpInside)
                
        //if the user is not already signed in present loginOptions viewcontroller
        if Auth.auth().currentUser == nil {
            guard let loginoptionvc = self.storyboard?.instantiateViewController(identifier: "loginNav") as? UINavigationController else {return}
            self.present(loginoptionvc, animated: true)
            
        }
        //loginoptionvc.modalPresentationStyle = .formSheet
        
        //        imageView.contentMode = .scaleAspectFit
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Uses last known location of user
            manager.stopUpdatingLocation()
    }
    
    private let uploadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.setImage(UIImage(named: "Upload_Icon"), for: .normal)
        return button
    }()
    
    
    //Upload Image Button
    @IBAction func didUploadTapButton() { //present image selection
        if Auth.auth().currentUser == nil {
            guard let loginoptionvc = self.storyboard?.instantiateViewController(identifier: "loginNav") as? UINavigationController else {return}
            self.present(loginoptionvc, animated: true)
            
        }
        else {
            guard let uploadvc = self.storyboard?.instantiateViewController(identifier: "uploadNav") as? UINavigationController else {return}
            //collectionvc.modalPresentationStyle =  .fullScreen
            self.present(uploadvc, animated: true)
        }
    }
    
    // Camera
    
    //Capture Session
    var session: AVCaptureSession?
    //Photo Output
    let output = AVCapturePhotoOutput()
    //Image Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    //Shutter Button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 8
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 166)
        uploadButton.center = CGPoint(x: view.frame.size.width/5, y: view.frame.size.height - 166)
    }
    
    
    
    private func checkCameraPermissions() {//makes sure the user has allowed to access camera
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
            break
        case.authorized:
            setUpCamera() // set up camera if already allowed
        @unknown default:
            break
        }
    }
    
    func setUpCamera() { //setting up camera function
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
                
                session.startRunning()
                self.session = session
            }
            catch {
                print("problem")
            }
        }
    }
    
    @objc private func didTapTakePhoto() {//captures photo
        if Auth.auth().currentUser == nil {
            guard let loginoptionvc = self.storyboard?.instantiateViewController(identifier: "loginNav") as? UINavigationController else {return}
            self.present(loginoptionvc, animated: true)
            
        }
        else {
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) { //getting photooutput and displaying it
        guard let data = photo.fileDataRepresentation() else { //photofile
            return
        }
        let image = UIImage(data: data)!
        //session?.stopRunning()//makes sure video feed isnt playing while viewing photo
        guard let snapViewer = self.storyboard?.instantiateViewController(identifier: "snapViewer") as? SnapshotViewController else {return}
        snapViewer.image = image
        snapViewer.modalPresentationStyle = .fullScreen
        //snapViewer.modalTransitionStyle = .crossDissolve
        self.present(snapViewer, animated: false)
    }
}













