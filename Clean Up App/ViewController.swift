//
//  ViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/24/21.
// Camera

import UIKit
import FirebaseStorage
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }
    @IBAction func didUploadTapButton() { //present image selection
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true) //change animated maybe
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        picker.dismiss(animated: true, completion: nil)
        
//        guard let metaData = info[UIImagePickerController.InfoKey.mediaMetadata] as? NSDictionary else {
//            print("error")
//            return
//        }
              // print metaDataDict to see it's keys and values
//        print("meta data = \(metaData.description)")
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { //makes sure image is a UIImage
            return
        }
        guard let imageData = image.pngData() else { //Makes sure image data is saved as PNG
            return
        }

        //date & time of imageupload
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium

        let datetime = formatter.string(from: now)
        
        let metadataDict = [
            "Longitude": "100",
            "Latitude": "150",
            "Time Created": datetime
        ]
        

        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png";
        metadata.customMetadata = metadataDict;
        
        //SampleUserName
        let username = ("Anpandoh")

        //uploadimagedata
        let ref = storage.child("images/" + datetime + " " + username)
        ref.putData(imageData, metadata: metadata, completion: { _, error in
            guard error == nil else {
                print("Failed to Upload")
                return
            }
            self.storage.child("images/" + datetime + " " + username).downloadURL(completion: {url, error in //gets download URL
                guard let url = url, error == nil else {return}
                let urlString = url.absoluteString
                print("Image URL:" + urlString)
                UserDefaults.standard.set(urlString, forKey: "url")
            })
        })
            
        //savedownload URL
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){ //dismisses selection screen
        picker.dismiss(animated: true, completion: nil)
    }

}






// Camera




