//
//  TabViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 6/24/21.
// Github Commit test Master Test

import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        var swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture)) //determining if they have swiped
        swipe.numberOfTouchesRequired = 1 //amount of fingers required to swipe
        swipe.direction = .left
        self.view.addGestureRecognizer(swipe)
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture)) //determining if they have swiped
        swipe.numberOfTouchesRequired = 1 //amount of fingers required to swipe
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
        
        self.selectedIndex = 1
    }
    @objc private func swipeGesture(swipe: UISwipeGestureRecognizer){//creating swipe gesture func
        switch swipe.direction{
        case .left:
            if selectedIndex < 3  { //stop after 3rd page
                self.selectedIndex = self.selectedIndex + 1
            }
            break
        case .right:
            if selectedIndex > 0 { //stop before 1st page
                self.selectedIndex = self.selectedIndex - 1
            }
            break
        default:
            break
        }
    }
}

//extension TabViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return TabViewAnimation()
//    }
//}
//
//class TabViewAnimation: NSObject, UIViewControllerAnimatedTransitioning {
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.2
//    }
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let destination = transitionContext.view(forKey: .to) else {return}
//
//        destination.transform = CGAffineTransform(translationX: 0, y: destination.frame.height)
//        transitionContext.containerView.addSubview(destination)
//
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {destination.transform = .identity}, completion: {transitionContext.completeTransition($0)})
//    }
//}
