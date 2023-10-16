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

/*
 SwiftLint configs Xcode 15
 https://thisdevbrain.com/swiftlint-permission-issue/
 */

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {

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
                                     ._printChanges()
                             },
                             withDependencies: {
                                 $0.dataManager = DataManager.fileSystem
                             }
                            )
            )
        }
    }
}
