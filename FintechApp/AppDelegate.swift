//
//  AppDelegate.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 13.09.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let rootAssembly = RootAssembly()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        if CommandLine.arguments.contains("UItesting") {
            configureAppForUITesting()
        }
        #endif
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
//        let rootVC = rootAssembly.presentationAssembly.conversationsListViewController()
//        let navController = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func configureAppForUITesting() {
        UIView.setAnimationsEnabled(false)
        self.window?.layer.speed = 100
    }
}
