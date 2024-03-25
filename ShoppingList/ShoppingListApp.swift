//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Max Tymchii on 03.09.2023.
//

import SwiftUI
import UIKit

import ComposableArchitecture
import ListManager
import Utils
import PurchaseList
import FirebaseCore
import FirebaseAnalytics
import Firebase
import Analytics
import ComposableAnalytics
import Note
import Tips
import TipKit
import Theme
/*
 SwiftLint configs Xcode 15
 https://thisdevbrain.com/swiftlint-permission-issue/
 */

public struct ApplicationTipConfiguration {
    
    /// The `DatastoreLocation` that `Tips` will use when configured. In this example, the Tips data store is located in the app's Application Support Directory.
    public static var storeLocation: Tips.ConfigurationOption.DatastoreLocation {
        var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        url = url.appending(path: "tipstore")
        return .url(url)
    }
    
    /// The `DisplayFrequency` used by `Tips`. In this example, `Tip`s will show immediately.
    public static var displayFrequency: Tips.ConfigurationOption.DisplayFrequency {
        .daily
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ShoppingListApp: App {
    @Dependency(\.userDefaultsManager) var userDefaultsManager
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
            ListManager(
                store: Store(initialState: ListManagerFeature.State(purchaseListCollection: []),
                             reducer: {
                                 ListManagerFeature()
                                     .dependency(\.analyticsClient,
                                                  AnalyticsClient.merge(
                                                    .consoleLogger,
                                                    .firebaseClient))
//                                     ._printChanges()
                             },
                             withDependencies: {
                                 $0.dataManager = DataManager.liveValue
                             }
                            )
            )
            .onAppear {
                Firebase.Analytics.logEvent("ThisISATest", parameters: ["title": "AppDelegate"])
            }
            .task {
                setupAppIcon()
            }
        }
    }
    
    private func setupAppIcon() {        
        ColorManager
            .shared
            .$currentColorScheme
            .receive(on: DispatchQueue.main)
            .throttle(for: .seconds(1),
                      scheduler: DispatchQueue.main,
                      latest: true)
            .sink { userInterfaceStyle in
            presetAppIcon(for: userInterfaceStyle)
        }
        .store(in: &ColorManager.shared.cancellables)
        
    }
    
    private func presetAppIcon(for userInterfaceStyle: UIUserInterfaceStyle) {
        
        var title = "AppIcon"
        
        if userInterfaceStyle == .dark {
            title.append("-Dark")
        } else {
            title.append("-Light")
        }
        print("Current user interface style: \(userInterfaceStyle.rawValue)")
        print("Saved user interface style: \(userDefaultsManager.userInterfaceStyle().rawValue)")
        
        if userDefaultsManager.userInterfaceStyle() != userInterfaceStyle {
            
            UIApplication.shared.setAlternateIconName(title) { (error) in
                if let error = error {
                    print("Failed request to update the app’s icon: \(error) with Title: \(title)")
                }
                
                userDefaultsManager.setUserInterfaceStyle(userInterfaceStyle)
                print("Updated user interface style: \(userDefaultsManager.userInterfaceStyle().rawValue)")
            }
            
            
          
        }
        
    }

    
    init() {
        
        
        // #if DEBUG
        //        /// Optionally, call `Tips.resetDatastore()` before `Tips.configure()` to reset the state of all tips. This will allow tips to re-appear even after they have been dismissed by the user.
        //        /// This is for testing only, and should not be enabled in release builds.
        ////        try? Tips.resetDatastore()
        //        Tips.showAllTipsForTesting()
        // #endif
        
        //        try? Tips.configure(
        //            [
        //                // Reset which tips have been shown and what parameters have been tracked, useful during testing and for this sample project
        //                .datastoreLocation(.applicationDefault),
        //
        //                // When should the tips be presented? If you use .immediate, they'll all be presented whenever a screen with a tip appears.
        //                // You can adjust this on per tip level as well
        //                    .displayFrequency(.immediate)
        //            ])
        try? Tips.configure([.datastoreLocation(ApplicationTipConfiguration.storeLocation),
                             .displayFrequency(ApplicationTipConfiguration.displayFrequency)])
    }
}
