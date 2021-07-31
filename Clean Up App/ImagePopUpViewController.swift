//
//  ImagePopUpViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/29/21.
//

import UIKit


class ImagePopUpViewController: UIViewController { //fix error where the loaded image is one behind
    
    @IBOutlet var imageView: UIImageView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit //can change
        imageView.transform = imageView.transform.rotated(by: .pi/2) //change orientation
        
        self.imageView.image = image
        
        
    }

}
