//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Max Tymchii on 03.09.2023.
//

import SwiftUI
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
/*
 SwiftLint configs Xcode 15
 https://thisdevbrain.com/swiftlint-permission-issue/
 */

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
                                     ._printChanges()
                             },
                             withDependencies: {
                                 $0.dataManager = DataManager.liveValue
                             }
                            )
            )
            .onAppear {
                Firebase.Analytics.logEvent("ThisISATest", parameters: ["title": "AppDelegate"])
            }

        }
    }

    init() {
#if DEBUG
        /// Optionally, call `Tips.resetDatastore()` before `Tips.configure()` to reset the state of all tips. This will allow tips to re-appear even after they have been dismissed by the user.
        /// This is for testing only, and should not be enabled in release builds.
        try? Tips.resetDatastore()
//        Tips.showAllTipsForTesting()
#endif

        try? Tips.configure(
            [
                // Reset which tips have been shown and what parameters have been tracked, useful during testing and for this sample project
                .datastoreLocation(.applicationDefault),

                // When should the tips be presented? If you use .immediate, they'll all be presented whenever a screen with a tip appears.
                // You can adjust this on per tip level as well
                    .displayFrequency(.immediate)
            ])
    }
}
