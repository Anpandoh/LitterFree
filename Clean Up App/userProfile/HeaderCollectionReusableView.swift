//
//  HeaderCollectionReusableView.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/22/22.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "HeaderCollectionReusableView"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .systemGreen
        addSubview(title)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = CGRect(x: bounds.minX + 5, y: bounds.minY + 5, width: bounds.width, height: bounds.height)

        
    }
    
    
    var title: UILabel = {
        let title =  UILabel()
        title.clipsToBounds = true
        title.text = "Your Recent Submissions:"
        title.font = UIFont(name:"Bodoni 72 Oldstyle Book", size: 30.0)

        //title.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3)
        title.textColor = UIColor.init(red: 48/255, green: 209/255, blue: 88/255, alpha: 1)
        return title
    }()
    
  
    
    
    func noSubmissions(isEmpty: Bool) {
        if isEmpty {
            title.textColor = .systemRed
            title.text = "You Have No Recent Submissions"
            title.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)

            
            
//            let bottomLine = CALayer()
//
//            bottomLine.frame = CGRect(x: title.frame.minX - 2, y: title.frame.minY + 35, width: title.frame.width - 100, height: 1)
//
//
//            bottomLine.backgroundColor = UIColor.init(red: 255/255, green: 10/255, blue: 10/255, alpha: 1).cgColor
//
//            // Add the line to the text field
//            title.layer.addSublayer(bottomLine)
        }
    }
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
