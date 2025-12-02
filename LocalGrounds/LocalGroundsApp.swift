//
//  LocalGroundsApp.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//main app file, mvvm and firebase data
import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

@main
struct LocalGroundsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
       var body: some Scene {
           WindowGroup {
               ContentView()
               //make vms available
                   .environmentObject(LoginViewModel())
                   .environmentObject(FavoritesViewModel())
                   .environmentObject(NotesViewModel())
                   .environmentObject(CafeListViewModel())
           }
       }
   }

//this gets called when app first launches
//for firebase config
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool { //uses info plist
        FirebaseApp.configure()
        return true
    }
}
