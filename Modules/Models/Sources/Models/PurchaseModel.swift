//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.10.2023.
//

import Foundation

public struct PurchaseModel: Codable, Identifiable {
    public let id: UUID
    public let notes: [NoteModel]
    public var title: String

    public init(id: UUID, notes: [NoteModel], title: String) {
        self.id = id
        self.notes = notes
        self.title = title
    }

    public static func newPurchase() -> Self {
        return .init(id: UUID(), notes: [], title: "New purchase list")
    }

}
