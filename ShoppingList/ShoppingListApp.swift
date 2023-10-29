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
import Emoji

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
//            EmojiView(store: Store(initialState: EmojiViewFeature.State(emoji: "",
//                                                                        emojisPull: []),
//                                   reducer: {
//                EmojiViewFeature()
//            }))
//            DraftList(store: Store(initialState:
//                                    DraftListFeature
//                .State(rawList:
//                        ["This is a true story about my childhood",
//                         "Milk",
//                         "Bread"]),
//                                   reducer: {
//                DraftListFeature()
//            }))
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
}
