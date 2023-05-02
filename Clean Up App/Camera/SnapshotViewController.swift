//
//  SnapshotViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/2/21.
//

import UIKit
import FirebaseDatabase
import Firebase








class SnapshotViewController: UIViewController {
    

    private let image: UIImage
    private let TrashCart: [Trashmarkers]?
    private let trashCleaned: Trashmarkers?
    private var type: Int8

    
    //3 Types, 0 - main VC, 1 - CleanUp VC, 2 - TrashCan VC
    
    
    init(snapShotImage: UIImage){
        self.image = snapShotImage
        self.type = 0
        self.TrashCart = nil
        self.trashCleaned = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(snapShotImage: UIImage, trashCleaned: Trashmarkers){
        self.image = snapShotImage
        self.trashCleaned = trashCleaned
        self.type = 1
        self.TrashCart = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(snapShotImage: UIImage, TrashCart: [Trashmarkers]){
        self.image = snapShotImage
        self.TrashCart = TrashCart
        self.trashCleaned = nil
        self.type = 2
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.contentMode = .scaleAspectFill
        self.view.backgroundColor = UIColor.red
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(didTapDismissButton))
        if (type == 0) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm Location", style: .plain, target: self, action: #selector(didTapConfirmButton))
        } else if (type == 1) {
            //Add subview explaining that you have to take a picture of cleaned up area
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add to Cart", style: .plain, target: self, action: #selector(didTapAddToCart))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Cart", style: .plain, target: self, action: #selector(didTapSubmitCart))

        }
        navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
//        navigationItem.rightBarButtonItem?.set = .systemGreen

        
        
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
    }
    
    @objc private func didTapDismissButton() {
        dismiss(animated: false)
    }
    
    
    
    
    
    @objc func didTapConfirmButton() {
        let selectLocation  = SelectLocationController(snapShotImage: image)
        selectLocation.view.backgroundColor = .green
        navigationController?.pushViewController(selectLocation, animated: true)
        
    }
    
    @objc func didTapAddToCart() {
        //remove pin

        
        //(Pass through a trashmarker)
        
        //add to cart
        var tcv = TrashCartView()
        tcv.TrashCart.append(trashCleaned!)
        
        
        print("Added to Cart")
        dismiss(animated: false)
    }

    @objc func didTapSubmitCart() {
        let mvc = MapViewController()
        
        for trash in TrashCart! {
            //Remove from Firebase
            print(trash.firebaseQuery)

            //Remove from map
            mvc.mapView.removeAnnotation(trash)
            
        }
        
        //Remove from TrashCartView
        var tcv = TrashCartView()
        tcv.TrashCart.removeAll()
        
        //dismiss back to Mapview
        dismiss(animated: false)

    }
    
    
}


