import Foundation
import ComposableArchitecture
import Dependencies
import Models
import NonEmpty
import Validated

public struct DataManager {
    public var loadData: @Sendable () async -> Validated<[PurchaseModel], NonEmptyArray<Error>>
}

extension DataManager: DependencyKey {
    public static var liveValue: Self {
        return DataManager {
            return unimplemented("DataManager.load")
        }
    }

    public static var previewValue: Self {
        return DataManager {
            return readSomeFilesList()
        }
    }

    public static var fileSystem: Self {
        return DataManager {
            return .valid(PurchaseModel.mock.flatMap { $0} )
        }
    }

    private static func readSomeFilesList() -> Validated<[PurchaseModel], NonEmptyArray<Error>> {
        let controller = FileIOController()
        do {
            let list: [PurchaseModel] = try controller.readAll()
            return .valid(list)
        } catch {
            return .error(NonEmptyArray(error))
        }
    }


    private static func writeSomeFile() {
        let controller = FileIOController()
        let purchase = PurchaseModel.fabric()
        do {
            try controller.write(purchase, toDocumentNamed: purchase.id.uuidString)
            print("Write succeed")
        } catch {
            print("Get error on write \(error)")
        }
    }

}

public extension DependencyValues {
  var dataManager: DataManager {
    get { self[DataManager.self] }
    set { self[DataManager.self] = newValue }
  }
}
