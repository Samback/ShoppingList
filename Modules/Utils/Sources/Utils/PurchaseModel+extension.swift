//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.10.2023.
//

import Foundation
import Models
import ComposableArchitecture
import NonEmpty

extension PurchaseModel {
    static var index = 0
    private static var mockNotes = [
        NoteModel(id: nextUUID(), title: "Milk", isCompleted: false),
        NoteModel(id: nextUUID(), title: "Bread", isCompleted: false),
        NoteModel(id: nextUUID(), title: "Water", isCompleted: false),
        NoteModel(id: nextUUID(), title: "Beer", isCompleted: false)
    ]

    static var mock: NonEmptyArray<PurchaseModel> = {

        return NonEmptyArray(PurchaseModel(id: nextUUID(), notes: mockNotes, title: "My shopping list"))
    }()

    static func fabric(uuid: UUID = nextUUID()) -> PurchaseModel {
        return PurchaseModel(id: uuid,
                             notes: mockNotes,
                             title: "My shopping list \(uuid.uuidString.dropLast(10))")
    }

    static func nextUUID() -> UUID {
        index += 1
        return UUID(index)
    }
}
