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

    public static func newPurchase(title: String) -> Self {
        return .init(id: UUID(), notes: [], title: title)
    }

    public func duplicate(uuid: UUID = .init()) -> Self {
        return .init(id: uuid, notes: notes, title: title)
    }

   public func shareVersion() -> String {
       return notes.reduce(title + "\n") { result, note in
           return result + note.title + " " + note.isCompleted.emoji + "\n"
       }
    }

}
