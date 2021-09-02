//
//  CollectionViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/29/21.
//

import UIKit
import Photos
import Foundation

private let reuseIdentifier = "Cell"


class CollectionViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    @IBOutlet weak var moreimagesButton: UIButton!

        
        private var images = [PHAsset]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            populatePhotos()
            moreimagesButton.alpha = 0
        }
        
        private func setupUI() {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.images.count
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as? PhotosCollectionViewCell else {
                fatalError("PhotoCollectionViewCell is not found")
            }
            
            let asset = self.images[indexPath.row]
            let manager = PHImageManager.default()
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, _ in
                
                DispatchQueue.main.async {
                    cell.photoImageView.image = image
                }
                
            }
            
            return cell
            
        }
        
        private func populatePhotos() {
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                
                if status == .authorized {
                    
                    self?.getImages()
                    
                    
                }
                if status == PHAuthorizationStatus.limited {
                    self?.getImages()
                    DispatchQueue.main.async {
                    self?.moreimagesButton.alpha = 1
                    }
                }
                
                if status == PHAuthorizationStatus.denied {
                    print("denied access")
                    return
                }
                
                                            
                
            }
            
        }
    
    private func getImages () {
        self.images.removeAll()
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        PHPhotoLibrary.shared().register(self)
        
        assets.enumerateObjects { (object,_, _) in
            self.images.append(object)
        }
        
        self.images.reverse()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPaths = collectionView.indexPathsForSelectedItems{
                let uploadController = segue.destination as! UploadViewController
                uploadController.asset = images[indexPaths[0].row]
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            performSegue(withIdentifier: "showDetail", sender: nil)
        }
    
    @IBAction func moreimagesTapped() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getImages()
        
    }
}
