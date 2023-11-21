import Foundation
import ComposableArchitecture
import Dependencies
import Models
import NonEmpty
import Validated

public struct DataManager {
    public var loadData: @Sendable () async throws -> [PurchaseModel]
    public var deleteDocument: @Sendable (String) async throws -> Void
    public var createDocument: @Sendable (PurchaseModel) async throws -> Void
    public var loadAccount: @Sendable () async throws -> AccountModel
    public var saveAccount: @Sendable (AccountModel) async throws -> Void
}

extension DataManager: DependencyKey {
    private static let shoppingListManager = FileIOController(nestedFolderName: "ShoppingList")
    private static let accountManager = FileIOController(nestedFolderName: "Account")

    public static var liveValue: Self {
        return DataManager(loadData: { try readAllPurchases() },
                           deleteDocument: { try deletePurchase(name: $0) },
                           createDocument: { purchase in try write(purchase: purchase) },
                           loadAccount: { try loadAccount() },
                            saveAccount: { account in try saveAccount(account) }
        )
    }

    public static var previewValue: Self {
        return DataManager(loadData: { [PurchaseModel.fabric()] },
                           deleteDocument: { _ in },
                           createDocument: { _ in _ = PurchaseModel.fabric() },
                           loadAccount: { AccountModel(list: []) },
                           saveAccount: { _ in })

    }

    private static func readAllPurchases() throws -> [PurchaseModel] {
         try shoppingListManager.readAll()
    }

    private static func deletePurchase(name: String) throws {
        try shoppingListManager.delete(document: name)
    }

    private static func write(purchase: PurchaseModel) throws {
        try shoppingListManager.write(purchase, toDocumentNamed: purchase.id.uuidString)
    }

    private static func loadAccount() throws -> AccountModel {
        guard let accountModel: AccountModel = try accountManager.readAll().first else {
            let list = try readAllPurchases().map(\.id)
            let account = AccountModel(list: list)
            try saveAccount(account)
            return account
        }

        return accountModel
    }

    private static func saveAccount(_ account: AccountModel) throws {
        try accountManager.write(account, toDocumentNamed: "account")
    }

}

public extension DependencyValues {
  var dataManager: DataManager {
    get { self[DataManager.self] }
    set { self[DataManager.self] = newValue }
  }
}
