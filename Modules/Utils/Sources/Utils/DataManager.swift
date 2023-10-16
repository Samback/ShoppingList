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
}

extension DataManager: DependencyKey {
    public static var liveValue: Self {
        return DataManager(loadData: { try readAllDocuments() },
                           deleteDocument: { try deleteDocument(name: $0) },
                           createDocument: { purchase in try write(purchase: purchase) })
    }

    public static var previewValue: Self {
        return DataManager(loadData: { [PurchaseModel.fabric()] },
                           deleteDocument: { _ in },
                           createDocument: { _ in _ = PurchaseModel.fabric() })

    }

    public static var fileSystem: Self {
        return DataManager(loadData: { try readAllDocuments() },
                           deleteDocument: { try deleteDocument(name: $0) },
                           createDocument: { purchase in
            try write(purchase: purchase) })
    }

    private static func readAllDocuments() throws -> [PurchaseModel] {
         try FileIOController().readAll()
    }

    private static func deleteDocument(name: String) throws {
        let controller = FileIOController()
        try controller.delete(document: name)
    }

    private static func write(purchase: PurchaseModel) throws {
        let controller = FileIOController()
        try controller.write(purchase, toDocumentNamed: purchase.id.uuidString)
    }

}

public extension DependencyValues {
  var dataManager: DataManager {
    get { self[DataManager.self] }
    set { self[DataManager.self] = newValue }
  }
}
