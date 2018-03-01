//
//  AppDelegate.swift
//  cultivate
//
//  Created by Akshit Zaveri on 18/12/17.
//  Copyright © 2017 Akshit Zaveri. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics
import FBSDKCoreKit
import GoogleSignIn
import IQKeyboardManagerSwift
import SWRevealViewController

import Contacts

var hamburgerMenuVC: CULHamburgerMenuVC!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.CNContactStoreDidChange, object: nil, queue: nil) { (notification) in
//            ContactsWorker().updateCultivateContacts()
//        }
        
        window?.tintColor = #colorLiteral(red: 0.3764705882, green: 0.5764705882, blue: 0.4039215686, alpha: 1)
        
        //        FirebaseConfiguration.shared.setLoggerLevel(.error)
        // TODO: Remove below line
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(true)
        FirebaseApp.configure()
        
        CULFirebaseGateway.shared.localPersistence(false)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        IQKeyboardManager.sharedManager().enable = true
        
        if let currentUser = Auth.auth().currentUser {
            
            print("Current user: \(currentUser.uid)")
            
            let authStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
            let extendedSplashVC: ExtendedSplashVC = authStoryboard.instantiateViewController(withIdentifier: "ExtendedSplashVC") as!ExtendedSplashVC
            self.window?.rootViewController = extendedSplashVC
            self.window?.makeKeyAndVisible()
            
            CULUser.checkIfUserExist(with: currentUser.uid, completion: { (loggedInUser, success) in
                DispatchQueue.main.async {
                    
                    let userPersonalNameFromGeneralSettings = UIDevice.current.name
                    CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.name, value: userPersonalNameFromGeneralSettings)
                    
                    let iOSVersion = UIDevice.current.systemVersion
                    CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.iOSVersion, value: iOSVersion)
                    
                    let model = UIDevice.current.model
                    CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.deviceModel, value: model)
                    
                    CULFirebaseAnalyticsManager.shared.set(property: CULFirebaseAnalyticsManager.Keys.UserProperties.lastUserLogin, value: Date())
                    
                    CULFirebaseGateway.shared.loggedInUser = loggedInUser
                    guard let user = loggedInUser else {
                        
                        let welcomeNavigationController: UINavigationController = authStoryboard.instantiateViewController(withIdentifier: "navWelcomeVC") as! UINavigationController
                        self.window?.rootViewController = welcomeNavigationController
                        
                        return
                    }
                    
                    ContactsWorker().updateCultivateContacts()
                    
                    if user.isOnBoardingComplete == true {
                        // Show dashboard
                        let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                        let revealViewController = dashboardStoryboard.instantiateInitialViewController() as! SWRevealViewController
                        self.window?.rootViewController = revealViewController
                        hamburgerMenuVC = revealViewController.rearViewController as! CULHamburgerMenuVC
                    } else {
                        // Show onboarding
                        let onboardingStoryboard: UIStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
                        let welcomeNavController: UINavigationController = onboardingStoryboard.instantiateInitialViewController() as! UINavigationController
                        self.window?.rootViewController = welcomeNavController
                    }
                    
                    self.window?.makeKeyAndVisible()
                }
            })
        } else {
            let authStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
            let welcomeNavigationController: UINavigationController = authStoryboard.instantiateViewController(withIdentifier: "navWelcomeVC") as! UINavigationController
            self.window?.rootViewController = welcomeNavigationController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.contains("google") {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        } else {
            let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            return handled
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ContactsWorker().updateCultivateContacts()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name("applicationDidBecomeActive_Dashboard"), object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //    private func testFirestore() {
    //        let store: Firestore = Firestore.firestore()
    //        let data: [String:Any] = [
    //            "first": "Akshit2",
    //            "last": "Zaveri3",
    //            "born": 1990
    //        ]
    //        _ = store.collection("users").addDocument(data: data) { (error) in
    //            if let error = error {
    //                print(error)
    //            } else {
    //                print("Success")
    //            }
    //        }
    //    }
    //
    //    private func getDataFromFirestore() {
    //        let store = Firestore.firestore()
    //        store.collection("usersTestAkshit1").getDocuments { (snapshot, error) in
    //            for document in snapshot?.documents ?? [] {
    //                print(document)
    //            }
    //        }
    //    }
}

