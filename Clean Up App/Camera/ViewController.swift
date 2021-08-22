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



class ViewController: UIViewController, PHPickerViewControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    
    

    
    
//    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    private var userImages = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = PHPickerFilter.any(of: [.images, .livePhotos])
            config.selectionLimit = 1
            let vc = PHPickerViewController(configuration: config)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]){
        picker.dismiss(animated: true, completion: nil)
        
        
        //creating a dispatch group to make images save to array properly
        let group = DispatchGroup()
        var latitude = ""
        var longitude = ""
        var photodate = ""
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        
        
        results.forEach {result in //gathering the metadata
            if let assetId = result.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                
                let defaultdate = Date(timeIntervalSince1970: 0.0)
                photodate =  formatter.string(from: assetResults.firstObject?.creationDate ?? defaultdate)//if date cannot be found as for date
                latitude = String((assetResults.firstObject?.location?.coordinate.latitude) ?? 0.0)//create a function that if longitude and latitude = 0.0 ask for real location
                longitude = String((assetResults.firstObject?.location?.coordinate.longitude) ?? 0.0)
                print(photodate)
                print(latitude)
                print(longitude)
            }
            
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                self?.userImages.append(image)
            }
        }
        
        group.notify(queue: .main) {
            if self.userImages.count != 0 {
                guard let imageData = self.userImages[0].pngData() else { //fix if picker is canceled
                    return
                }
                
                //date & time of imageupload
                let imguploadtime = formatter.string(from: now)
                
                //metadata uploading
                let metadataDict = [
                    "Latitude": latitude,
                    "Longitude":longitude,
                    "Date":photodate
                ]
                
                
                
                let Metadata = StorageMetadata()
                //Metadata.contentType = "images/png" FIREBASE IS BROKEN AND WILL ONLY ALLOW CUSTOM METADATA IF CONTENTTYPE AND OTHERS REMAIN UNSPECIFIED
                Metadata.customMetadata = metadataDict;
                
                //SampleUserName
                let usernameEmail = Auth.auth().currentUser?.email
                
                //uploadimagedata
                let ref = self.storage.child("images/" + imguploadtime + " " + usernameEmail!)
                ref.putData(imageData, metadata: Metadata, completion: { _, error in
                    guard error == nil else {
                        print("Failed to Upload")
                        return
                    }
                    self.storage.child("images/" + imguploadtime + " " + usernameEmail!).downloadURL(completion: {url, error in //gets download URL
                        guard let url = url, error == nil else {return}
                        let urlString = url.absoluteString
                        print("Image URL:" + urlString)
//                        UserDefaults.standard.set(urlString, forKey: "url")
                        self.userImages.removeAll()
                    })
                })
                func imagePickerControllerDidCancel(_ picker: UIImagePickerController){ //Cancel button
                    picker.dismiss(animated: true, completion: nil)
                }
            }
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













