//
//  ViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/24/21.
// Camera

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //Capture Session
    var session: AVCaptureSession?
    //Photo Output
    let output = AVCapturePhotoOutput()
    //Video preview
    let previewlayer = AVCaptureVideoPreviewLayer()
    //shutter button
    private let shutterbutton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    } ()
    
    
    override func viewDidLoad() { //viewdidload
        super.viewDidLoad()
        checkCameraPermissions()
        view.layer.addSublayer(previewlayer)
        view.addSubview(shutterbutton)
        
        shutterbutton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside) //connecting the button to it's action
    }
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        previewlayer.frame = view.bounds
        shutterbutton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
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
    private func setUpCamera() { //setting up camera function
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
                previewlayer.videoGravity = .resizeAspectFill //resize the video
                previewlayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch {
                print("problem")
            }
        }
    }
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) { //getting photooutput and displaying it
        guard let data = photo.fileDataRepresentation() else { //photofile
            return
        }
        let image = UIImage(data: data)
        session?.stopRunning() //makes sure video feed isnt playing while viewing photo
        let imageView = UIImageView(image:image)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView) //addbutton to exit out of image view
    }

}

