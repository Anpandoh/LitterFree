//
//  SnapshotViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/2/21.
//

import UIKit







class SnapshotViewController: UIViewController {
    

    private let image: UIImage

    
    init(snapShotImage: UIImage){
        self.image = snapShotImage
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm Location", style: .plain, target: self, action: #selector(didTapConfirmButton))
        navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen
//        navigationItem.rightBarButtonItem?.set = .systemGreen

        //navigationItem.leftBarButtonItem?.setBackgroundImage(<#T##backgroundImage: UIImage?##UIImage?#>, for: <#T##UIControl.State#>, style: <#T##UIBarButtonItem.Style#>, barMetrics: <#T##UIBarMetrics#>)
        //navigationItem.leftBarButtonItem?.style = .plain
        
        
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

    
    
}


