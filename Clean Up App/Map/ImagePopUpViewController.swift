//
//  ImagePopUpViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/29/21.
//

import UIKit
import FirebaseStorage
let storage = Storage.storage().reference()



class ImagePopUpViewController: UIViewController { //fix error where the loaded image is one behind
    
    @IBOutlet var imageView: UIImageView!
    
    var imgInfo: String = ""
    
    override func viewDidLoad() {
        displayImage()
        //print(imgInfo)
        
        imageView.contentMode = .scaleAspectFill //can change
        //imageView.transform = imageView.transform.rotated(by: .pi/2) //change orientation
        imageView.frame = view.bounds
        
        
        view.addSubview(progressView)
        progressView.setProgress(0, animated: false)
        progressView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: 20)
    }
    
    //Progress Bar
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .white
        progressView.progressTintColor = .green
        return progressView
    }()
    
    
    
    //sets the image
    func setImage(info: String) {
        imgInfo = info;
    }
    
    
    let imageCache = NSCache<NSString, UIImage>()//caches images for faster loadtime
    
    //Displays the image
    func displayImage() {
        let pinImg = imgInfo
        let imageloader = storage.child(pinImg)
        imageloader.downloadURL(completion: {url, error in //fetches download url
            guard let url = url, error == nil else{
                return
            }
            let urlString = url.absoluteString
            print(urlString)
            if let imageFromCache = self.imageCache.object(forKey: urlString as NSString) {
                self.imageView.image = imageFromCache
            }//checks for cached image
            else {//If nothing in cache
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in //downloads the image data
                    guard let data = data,  error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        let imageToCache = UIImage(data: data)!
                        self.imageCache.setObject(imageToCache, forKey: urlString as NSString)
                        self.imageView.image = imageToCache
                    }
                })
                self.progressView.observedProgress = task.progress //Updates progress bar
                task.resume()
                
            }
        })
    }
}
