//
//  HassadakApp.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//

import SwiftUI

@main
struct HassadakApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView() //
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        return true
    }
}
