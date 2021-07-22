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

class ViewController: UIViewController, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    private var userImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }
    //Upload Image Button
    @IBAction func didUploadTapButton() { //present image selection
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        config.selectionLimit = 1
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
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
            print(self.userImages.count)
            if self.userImages.count != 0 {
                guard let imageData = self.userImages[0].jpegData(compressionQuality: 1) else { //fix if picker is canceled
                    return
                }
                
                //date & time of imageupload
                let imguploadtime = formatter.string(from: now)
                
                //metadata uploading
                let metadataDict = [
                    "Latitude": latitude,
                    "Longitude": longitude,
                    "Date Created": photodate
                ]
                
                
                
                let metadata = StorageMetadata()
                metadata.contentType = "images/jpeg";
                metadata.customMetadata = metadataDict;
                
                //SampleUserName
                let username = ("Anpandoh")
                
                //uploadimagedata
                let ref = self.storage.child("images123/" + imguploadtime + " " + username)
                ref.putData(imageData, metadata: metadata, completion: { _, error in
                    guard error == nil else {
                        print("Failed to Upload")
                        return
                    }
                    self.storage.child("images123/" + imguploadtime + " " + username).downloadURL(completion: {url, error in //gets download URL
                        guard let url = url, error == nil else {return}
                        let urlString = url.absoluteString
                        print("Image URL:" + urlString)
                        UserDefaults.standard.set(urlString, forKey: "url")
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
    
    
    
    
}











