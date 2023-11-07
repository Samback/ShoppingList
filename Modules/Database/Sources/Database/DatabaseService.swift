import Foundation
import SwiftData
import Dependencies

public extension DependencyValues {
    var databaseService: DatabaseService {
        get { self[DatabaseService.self] }
        set { self[DatabaseService.self] = newValue }
    }
}

private let appContext: ModelContext = {
    do {
        let url = URL.applicationSupportDirectory.appending(path: "Model.sqlite")
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(for: AppConfigurationModel.self, PurchaseListStoreModel.self, configurations: config)
        return ModelContext(container)
    } catch {
        fatalError("Failed to create container.")
    }
}()

public struct DatabaseService {
    var context: () throws -> ModelContext
}

extension DatabaseService: DependencyKey {
    public static let liveValue = Self(
        context: { appContext }
    )
}

extension DatabaseService: TestDependencyKey {
    public static var previewValue = Self.noop

    public static let testValue = Self(
        context: unimplemented("\(Self.self).context")
    )

    static let noop = Self(
        context: unimplemented("\(Self.self).context")
    )
}
