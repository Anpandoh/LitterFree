//
//  ViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/24/21.
// Camera

import UIKit
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    var x = 0
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }
    @IBAction func didUploadTapButton() { //present image selection
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true) //change animated maybe
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { //makes sure image is a UIImage
            return
        }
        guard let imageData = image.pngData() else { //Makes sure image data is saved as PNG
            return
        }
        let number = String(x)
        print(number)
        //uploadimagedata
        let ref = storage.child("images/file" + number + ".png")
        ref.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to Upload")
                return
            }
            self.storage.child("images/file" + number + ".png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {return}
                let urlString = url.absoluteString
                print("Image URL:" + urlString)
                UserDefaults.standard.set(urlString, forKey: "url")
            })
        })
            
        //getdownloadURL
        //savedownload URL
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){ //dismisses selection screen
        picker.dismiss(animated: true, completion: nil)
        x = x + 1
    }

}

