//
//  ImagePopUpViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/29/21.
//

import UIKit
//import FirebaseStorage
//let storage = Storage.storage()



class ImagePopUpViewController: UIViewController { //fix error where the loaded image is one behind
    
    @IBOutlet var imageView: UIImageView!
    
    var urlLink: String = ""
    //var testUrl = URL
    
    
    override func viewDidLoad() {
        //print(imgInfo)
        
        imageView.contentMode = .scaleAspectFit //can change
        //imageView.transform = imageView.transform.rotated(by: .pi/2) //change orientation
        imageView.frame = view.bounds
        
        
        //        view.addSubview(progressView)
        //        progressView.setProgress(0, animated: false)
        //        progressView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: 20)
        
        //Shows loading screen while metdata is being fetched
        
        
        
        //        let loadingVC = LoadingViewController()
        //
        //        // Animate loadingVC over the existing views on screen
        //        loadingVC.modalPresentationStyle = .overCurrentContext
        //
        //        // Animate loadingVC with a fade in animation
        //        loadingVC.modalTransitionStyle = .crossDissolve
        //
        //        self.present(loadingVC, animated: true, completion: nil)
        //
        displayImage()
        //
        //        loadingVC.dismiss(animated: true) //Dismisses the loading screen
        
    }
    
    
    
    
    //    //Progress Bar
    //    private let progressView: UIProgressView = {
    //        let progressView = UIProgressView(progressViewStyle: .default)
    //        progressView.trackTintColor = .white
    //        progressView.progressTintColor = .green
    //        return progressView
    //    }()
    //
    
    
    //sets the image
    func setImage(url: String) {
        self.urlLink = url;
    }
    
    
    var imageCache = ImageCache.getImageCache()
    
    //Displays the image
    func displayImage() {
        
        
        //        testUrl = abcd
        if let imageFromCache = imageCache.get(forKey: urlLink) {
            //            loadingVC.dismiss(animated: true) //Dismisses the loading screen
            
            print("Using Cache");
            self.imageView.image = imageFromCache
            
            return
        }//checks for cached image
        
        //If nothing in cache
        print("Not using Cache");
        
        //let url = URL(string: urlLink)!
        
        let httpsReference = storage.reference(forURL: urlLink)
        
        DispatchQueue.global().async {
            httpsReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        // Data for url is returned
                        if let imageToCache = UIImage(data: data!)  {
                            self.imageCache.set(forKey: self.urlLink, image: imageToCache)
                            self.imageView.image = imageToCache
                        }
                    }
                }
            }
            
            
            // Fetch Image Data
//            if let data = try? Data(contentsOf: url) {
//                DispatchQueue.main.async {
//                    // Create Image and Update Image View
//                    if let imageToCache = UIImage(data: data)  {
//                        self.imageCache.set(forKey: self.urlLink, image: imageToCache)
//                        self.imageView.image = imageToCache
//                    }
//                }
                // self.progressView.observedProgress = data.progress //Updates progress bar
                
           // }
        }
        //self.loadingVC.dismiss(animated: true)
        
    }
}


//class ImageCache {
//    var cache = NSCache<NSString, UIImage>()
//
//    func get(forKey: String) -> UIImage? {
//        return cache.object(forKey: NSString(string: forKey))
//    }
//
//    func set(forKey: String, image: UIImage) {
//        cache.setObject(image, forKey: NSString(string: forKey))
//    }
//}
//
//extension ImageCache {
//    private static var imageCache = ImageCache()
//    static func getImageCache() -> ImageCache {
//        return imageCache
//    }
//}
