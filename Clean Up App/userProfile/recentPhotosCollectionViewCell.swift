//
//  recentPhotosCollectionViewCell.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/20/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class recentPhotosCollectionViewCell: UICollectionViewCell {
    static let identifier = "recentPhotosCollectionViewCell"
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    
//    func setUrls (String x: String) {
//        urls.append(x)
//    }
    
    
    
    
    
    
    
    
}
