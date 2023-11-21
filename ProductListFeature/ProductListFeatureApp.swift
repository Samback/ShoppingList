//
//  ProductListFeatureApp.swift
//  ProductListFeature
//
//  Created by Max Tymchii on 13.11.2023.
//

import SwiftUI
import ComposableArchitecture
import PurchaseList
import FirebaseCore
import FirebaseAnalytics
import Firebase
import Analytics
import ComposableAnalytics
import Inject

@main
struct ProductListFeatureApp: App {

    @ObserveInjection var inject

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PurchaseList(store: .init(initialState: PurchaseListFeature.demo,
                                          reducer: {
                    PurchaseListFeature()
                }))
            }
            .enableInjection()
        }
    }
}
