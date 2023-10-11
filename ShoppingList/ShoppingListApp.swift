//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Max Tymchii on 03.09.2023.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

@main
struct ShoppingListApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
           ContentView()
        }
    }
}
