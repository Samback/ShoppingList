//
//  File.swift
//  
//
//  Created by Max Tymchii on 06.11.2023.
//

import Foundation
import SwiftData

@Model
public class PurchaseListStoreModel: Identifiable {
    public let id: UUID
    public var list: [UUID]

    public init(id: UUID, list: [UUID]) {
        self.id = id
        self.list = list
    }
}
