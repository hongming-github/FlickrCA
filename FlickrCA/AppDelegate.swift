//
//  AppDelegate.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UISplitViewControllerDelegate{
    
    var window: UIWindow?
    var results : SearchPhoto = SearchPhoto()
    var dbManage : DataManagement = DataManagement()
    var backgroundMusicPlayer = AVAudioPlayer()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //playBackgroundMusic("Snowdream")
        
        let tb:UITabBarController = window?.rootViewController as! UITabBarController
        
        let toViewController0:SearchViewController =
            tb.viewControllers![0] as! SearchViewController
        toViewController0.results = self.results
        
        let splitViewController = tb.viewControllers![1] as! UISplitViewController
        let navigationController1 = splitViewController.viewControllers[0] as! UINavigationController
        let toViewController1:PhotoResultsController =
            navigationController1.childViewControllers[0] as! PhotoResultsController
        toViewController1.results = self.results
        toViewController1.dbManage = self.dbManage
        navigationController1.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        splitViewController.delegate = self
        
        let navigationController3 = tb.viewControllers![2] as! UINavigationController
        let toViewController3:LikeViewController = navigationController3.childViewControllers[0] as!LikeViewController
        toViewController3.dbManage = self.dbManage
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(switchResultView),
            name: "switchResultView",
            object: nil)
        return true
    }
    
    func switchResultView() {
        let tb:UITabBarController =
            window?.rootViewController as! UITabBarController
        let fromView:UIView = tb.selectedViewController!.view;
        let toView:UIView! = tb.viewControllers?[1].view;
        
        // Transition using a page curl.
        UIView.transitionFromView(fromView, toView:toView,duration:0.5,
                                  options: UIViewAnimationOptions.TransitionCurlDown,
                                  completion:{(finished:Bool)-> Void in
                                    if (finished) {
                                        tb.selectedIndex = 1;
                                    }});
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? BigImageController else { return false }
        if topAsDetailController.bigImage == nil {
            return true
        }
        return false
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: "mp3")
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = 99
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}

