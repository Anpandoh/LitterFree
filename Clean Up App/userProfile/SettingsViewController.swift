//
//  SettingsViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/20/21.
//

import UIKit
import FirebaseAuth
import FirebaseOAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebaseDatabase

class SettingsViewController: UIViewController, FUIAuthDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userPointsLabel: UILabel!
    @IBOutlet weak var logOut: UIButton!
    var db: DatabaseReference!
    var images = [UIImage]()
    var noImages = true
    
    //On load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        leaderboardButton.addTarget(self, action: #selector(didTapLeaderboardButton), for: .touchUpInside)
        
        
    }
    
    let leaderboardButton: UIButton = { //Anonymous class
        let button = UIButton()
        button.setTitle("leaderboard", for: .normal)

        return button
    }()

    @objc func didTapLeaderboardButton() {
        let leaderboard = LeaderboardController()
        self.present(leaderboard, animated: true)
        
    }
    
    
    //add a UI Stack view
//    let verticalStack: UIStackView = {
//
//    }
    
    
    private func setUpElements(){
        Utilities.styleCancelButton(logOut)
        Utilities.styleLabelSimple(userLabel)
        Utilities.stylePointsLabel(userPointsLabel)
        leaderboardButton.bounds = CGRect(x: 0, y: 0, width: view.frame.width-80, height: 40)
        leaderboardButton.center = CGPoint(x: view.bounds.midX, y: 300)
        Utilities.styleHollowButton(leaderboardButton)
        //view.addSubview(leaderboardButton)
        
        
        userLabel.alpha = 0
        logOut.alpha = 0
        userPointsLabel.alpha = 0
        //view.backgroundColor = .systemIndigo
    }
    
    //Showing user label
    private func showUser(_ message:String) {
        userLabel.text = message
        userLabel.alpha = 1
        logOut.alpha = 1
    }
    
    //Showing user points
    private func showPoints() {
        let pointsHelper = userPoints()
        pointsHelper.getPoints(completion: {(points) in
                //print("The points returned:" + String(points) + "\n")
                self.userPointsLabel.text = "Your Points: " + String(points)
                self.userPointsLabel.alpha = 1
                
            })
        
        //userPointsLabel.text = String(message)
    }
    
    
    
    
    //Logout Button
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        loginScreen()
    }
    
    
    
    
    //On appearance
    override func viewDidAppear(_ animated: Bool) {
        //Checks for sign in
        if Auth.auth().currentUser != nil {
            guard let name = Auth.auth().currentUser?.displayName else {
                guard let email = Auth.auth().currentUser?.email else {
                    showUser("Signed in as: " + (Auth.auth().currentUser?.phoneNumber)!)
                    return
                }
                showUser("Signed in as: " + email)
                return
            }
            showUser("Signed in as: " + name)
            showPoints()
        }
        else {
            loginScreen()
        }
        
        
        
        //Collection view set up
        collectionView.register(recentPhotosCollectionViewCell.self, forCellWithReuseIdentifier: recentPhotosCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView .elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        
        
        //Loading in Images for Recent Images
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Cannot find userID")
            
        }
        
        
        db = Database.database().reference()
        let map = MapViewController()
        
        let userUploads = db.child("TrashInfo/" + LocationHelp.closestUserCity(UserLocation: map.manager.location!).name+"/"+userID)
        
        var counter = 0
        var urls = [String]()
        userUploads.observeSingleEvent(of: .value) {snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:String] else {
                    print("Error")
                    return
                }
                if (counter <= 6) {
                    urls.append(dict["url"] ?? "no url found")
                    counter += 1
                } else {
                    break
                }
                
            }
            
            DispatchQueue.global().async {
                // Fetch Image Data
                for url in urls {
                    if let data = try? Data(contentsOf: URL(string: url)!) {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data)  {
                                self.images.append(image)
                                self.images.reverse()
                            }
                        }
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
                
            }
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    
    
    
    //Populate the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentPhotosCollectionViewCell.identifier, for: indexPath) as? recentPhotosCollectionViewCell else {
            fatalError("recentPhotosCollectionViewCell is not found")
        }
        
        if (!images.isEmpty){
            let image = images[0]
            images.remove(at:0)
            noImages = false
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    //Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as? HeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        if (!noImages){
            header.noSubmissions(isEmpty: noImages)
        }
        
        
        return header
    }
    
    
    //Header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    //Size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width/3) - 3, height: (view.frame.width/3) - 3)
    }
    
    
    //Spacing between cells horizontal
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //Spacing between cells vertical
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    //Insets for each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
    
    //Log in screen to be called
    func loginScreen() {
        let authViewController = loginManager.loginScreen(delegate: self)
        present(authViewController, animated: true)
    }
    
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return customizedAuthViewController(authUI : authUI)
    }
    
    
    
}
