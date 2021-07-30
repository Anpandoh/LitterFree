//
//  ImagePopUpViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 7/29/21.
//

import UIKit


class ImagePopUpViewController: UIViewController { //fix error where the loaded image is one behind

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit //can change
        imageView.transform = imageView.transform.rotated(by: .pi/2) //change orientation
        
        guard let urlString = UserDefaults.standard.value(forKey: "Url") as? String,
              let url = URL(string: urlString) else {return}
        print(url) //the urlstring is behind
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data,  error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        })
        task.resume()
        print("okay")
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
