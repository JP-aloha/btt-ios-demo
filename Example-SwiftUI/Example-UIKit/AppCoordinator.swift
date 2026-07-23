//
//  AppCoordinator.swift
//
//  Created by Ashok Singh on 27/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator{
    
    static func setupRootTabVc(){
        if let rootVC = self.getRootTabVC(){
            switchRoot(sourceVC: rootVC)
        }
    }
    
    static func setupTutorialVc(){
        if let tutorialVC = self.getRootTutorialVC(){
            switchRoot(sourceVC: tutorialVC)
        }
    }
    
    static func setupRootConfigVc(){
        if let rootVC = self.getRootConfigVC(){
            switchRoot(sourceVC: rootVC)
        }
    }
    
    static private func switchRoot(sourceVC: UIViewController, completion: ((Bool) -> Void)? = nil){
        
       /* if let window  = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.1, options:[.transitionCrossDissolve, .curveEaseInOut], animations: {
                window!.rootViewController = sourceVC
                window!.makeKeyAndVisible()
            }, completion: { completed in
                if let completion = completion {
                    completion(true)
                }
            })
        }*/
        
        // Use a UIHostingController as window root view controller.
        let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate = scene?.delegate as? SceneDelegate, let window  = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.1, options:[.transitionCrossDissolve, .curveEaseInOut], animations: {
                window.rootViewController = sourceVC
                window.makeKeyAndVisible()
            }, completion: { completed in
                if let completion = completion {
                    completion(true)
                }
            })
        }
    }

    static private func getRootTabVC() ->TabBarViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarViewController
        return rootVC
    }
    
    static private func getRootConfigVC() ->UINavigationController?{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: "ConfigVC")
        let navRootVc = UINavigationController(rootViewController: rootVC)
        return navRootVc
    }
    
    static private func getRootTutorialVC() ->UINavigationController?{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialVC")
        let navTutorialVC = UINavigationController(rootViewController: tutorialVC)
        return navTutorialVC
    }
}

