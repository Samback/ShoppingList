//
//  File.swift
//  
//
//  Created by Max Tymchii on 05.11.2023.
//

import Foundation
import SwiftData

public enum SchemaV1: VersionedSchema {
    public static var versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [AppConfigurationModel.self, PurchaseListStoreModel.self]
    }
}
