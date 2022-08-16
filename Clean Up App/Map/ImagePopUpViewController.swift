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
    
    
    var imageCache = ImageCache.getImageCache()

    //Displays the image
    func displayImage() {
        let pinImg = imgInfo
        
        if let imageFromCache = imageCache.get(forKey: pinImg) {
            print("Using Cache");
            self.imageView.image = imageFromCache
            return
        }//checks for cached image
        
                //If nothing in cache
        print("Not using Cache");
        let imageloader = storage.child(pinImg)
        imageloader.downloadURL(completion: {[weak self] url, error in //fetches download url
            guard let url = url, error == nil else {
                return
            }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in //downloads the image data
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data)  {
                        self?.imageCache.set(forKey: pinImg, image: imageToCache)
                        self?.imageView.image = imageToCache
                    }
                }
                
            })
            self?.progressView.observedProgress = task.progress //Updates progress bar
            task.resume()
            
        })
    }
}


class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
