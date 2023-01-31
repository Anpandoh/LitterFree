//
//  CleanUpViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 1/20/23.
//

import UIKit
import AVFoundation


//Take a picture to verify clean up

class CleanUpViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.uploadButton.addTarget(self, action: #selector(didUploadTapButton), for: .touchUpInside)
        self.shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
        
        //Add label that explains that user should take a picture of the cleaned up area to add to cart

    }
    //change this
    @objc override func didUploadTapButton() {
        super.didUploadTapButton()
        print("hey")
    }
    
    @objc override func didTapTakePhoto() {
        super.didTapTakePhoto()
        print("hi")
    }
    
    
//    override func didTapTakePhoto() {
//        super.didTapTakePhoto()
//        print("hi")
//    }
    
//    override func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let data = photo.fileDataRepresentation() else { //photofile
//            return
//        }
//        let image = UIImage(data: data)!
//        //session?.stopRunning()//makes sure video feed isnt playing while viewing photo
////        guard let snapViewer = self.storyboard?.instantiateViewController(identifier: "snapViewer") as? SnapshotViewController else {return}
//        let snapViewer = SnapshotCleanUpVC(snapShotImage: image)
//        let navVC = UINavigationController(rootViewController: snapViewer)
//        navVC.modalPresentationStyle = .fullScreen
//        
//        navVC.title = "Hello"
//
//        //snapViewer.modalTransitionStyle = .crossDissolve
//        self.present(navVC, animated: false)
//    }
    
    //override shutter button func to take to a different snapshot view controller
    



}
