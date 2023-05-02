//
//  TrashCanPictureViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 1/24/23.
//

import UIKit
import AVFoundation

class TrashCanViewController: ViewController {
    
    let TrashCart: [Trashmarkers]
    
    init(TrashCart: [Trashmarkers]){
        self.TrashCart = TrashCart
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        
        checkCameraPermissions()
        //view.backgroundColor = .systemRed
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        //view.addSubview(uploadButton)
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        //uploadButton.addTarget(self, action: #selector(didUploadTapButton), for: .touchUpInside)
        
        //if the user is not already signed in present loginOptions viewcontroller
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(didTapDismissButton))
        navigationItem.leftBarButtonItem?.tintColor = .systemGreen
    }
    
    @objc private func didTapDismissButton() {
        dismiss(animated: false)
    }
    
    //    //captures photo
    @objc override func didTapTakePhoto() {
        super.didTapTakePhoto()
        print("hey")
    }
    
    
    override func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) { //getting photooutput and displaying it
        guard let data = photo.fileDataRepresentation() else { //photofile
            return
        }
        let image = UIImage(data: data)!
        //session?.stopRunning()//makes sure video feed isnt playing while viewing photo
        //        guard let snapViewer = self.storyboard?.instantiateViewController(identifier: "snapViewer") as? SnapshotViewController else {return}
        let snapViewer = SnapshotViewController(snapShotImage: image, TrashCart: TrashCart)
        let navVC = UINavigationController(rootViewController: snapViewer)
        navVC.modalPresentationStyle = .fullScreen
        
        //snapViewer.modalTransitionStyle = .crossDissolve
        self.present(navVC, animated: false)
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
