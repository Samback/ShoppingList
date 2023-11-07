////
////  File.swift
////
////
////  Created by Max Tymchii on 05.11.2023.
////
//
import Foundation
import SwiftData
import Dependencies

public extension DependencyValues {
    var swiftData: AppDatabase {
        get { self[AppDatabase.self] }
        set { self[AppDatabase.self] = newValue }
    }
}

public struct AppDatabase {
    public var appConfiguration: @Sendable () throws -> AppConfigurationModel
    public var purchaseListStore: @Sendable () throws -> PurchaseListStoreModel
}

extension AppDatabase: DependencyKey {

    public struct DatabaseError: Error {
        public let description: String
        public let code: Int

        static let add = Self(description: "Failed to add model", code: 1)
        static let remove = Self(description: "Failed to remove model", code: 2)
        static let accountModel = Self(description: "Failed to get account model", code: 3)
        static let appConfiguration = Self(description: "Failed to get app configuration", code: 4)
        static let purchaseListStore = Self(description: "Failed to get purchase list store", code: 5)
    }

    public static let liveValue = Self(
        appConfiguration: {
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = try context()
                let descriptor = FetchDescriptor<AppConfigurationModel>(sortBy: [SortDescriptor(\.id)])
                print("Number of items \(try databaseContext.fetch(descriptor).count)")
                guard let appConfiguration = try databaseContext.fetch(descriptor).first else {
                    let appConfiguration = AppConfigurationModel(isZoomOut: false)
                    databaseContext.insert(appConfiguration)
                    return appConfiguration
                }
                return appConfiguration
            } catch {
                throw DatabaseError.appConfiguration
            }
        }, purchaseListStore: {
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = try context()
                let descriptor = FetchDescriptor<PurchaseListStoreModel>(sortBy: [SortDescriptor(\.id)])
                guard let purchaseListStore = try databaseContext.fetch(descriptor).first else {
                    let purchaseListStore = PurchaseListStoreModel(id: UUID(), list: [])
                    databaseContext.insert(purchaseListStore)
                    return purchaseListStore
                }
                return purchaseListStore
            } catch {
                throw DatabaseError.purchaseListStore
            }
        }
    )
}

// public struct AppDatabase {
//    public var
////    public var purchaseModels: @Sendable () throws -> [PurchaseModel]
////    public var accountModel: @Sendable () throws -> AccountModel
////    public var add: @Sendable (PurchaseModel) throws -> Void
////    public var delete: @Sendable (PurchaseModel) throws -> Void
//
//   public struct DatabaseError: Error {
//       public let description: String
//       public let code: Int
//
//       static let add = Self(description: "Failed to add model", code: 1)
//       static let remove = Self(description: "Failed to remove model", code: 2)
//       static let accountModel = Self(description: "Failed to get account model", code: 3)
//
//    }
// }
//
// extension AppDatabase: DependencyKey {
//    public static let liveValue = Self(
//        purchaseModels: {
//            do {
//                @Dependency(\.databaseService.context) var context
//                let databaseContext = try context()
//                let descriptor = FetchDescriptor<PurchaseModel>(sortBy: [SortDescriptor(\.id)])
//                return try databaseContext.fetch(descriptor)
//            } catch {
//                return []
//            }
//        },
//        accountModel: {
//            do {
//                @Dependency(\.databaseService.context) var context
//                let databaseContext = try context()
//                let descriptor = FetchDescriptor<AccountModel>(sortBy: [SortDescriptor(\.id)])
//                guard let accountModel = try databaseContext.fetch(descriptor).first else {
//                    let accountModel = AccountModel(list: [])
//                    databaseContext.insert(accountModel)
//                    return accountModel
//                }
//                return accountModel
//            } catch {
//                throw DatabaseError.accountModel
//            }
//        },
//        add: { model in
//            do {
//                @Dependency(\.databaseService.context) var context
//                let movieContext = try context()
//
//                movieContext.insert(model)
//            } catch {
//                throw DatabaseError.add
//            }
//        },
//        delete: { model in
//            do {
//                @Dependency(\.databaseService.context) var context
//                let movieContext = try context()
//
//                let modelToBeDelete = model
//                movieContext.delete(modelToBeDelete)
//
//            } catch {
//                throw DatabaseError.remove
//            }
//        }
//    )
// }
//
// extension AppDatabase: TestDependencyKey {
//    public static var previewValue = Self.noop
//
//    public static let testValue = Self(
//        purchaseModels: unimplemented("\(Self.self).purchaseModels"),
//        accountModel: unimplemented("\(Self.self).accountModel"),
//        add: unimplemented("\(Self.self).add"),
//        delete: unimplemented("\(Self.self).delete")
//    )
//
//    static let noop = Self(
//        purchaseModels: unimplemented("\(Self.self).purchaseModels"),
//        accountModel: unimplemented("\(Self.self).accountModel"),
//        add: unimplemented("\(Self.self).add"),
//        delete: unimplemented("\(Self.self).delete")
//    )
//
// }
