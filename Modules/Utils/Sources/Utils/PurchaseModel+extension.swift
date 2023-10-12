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

    private static var mockNotes = [
        NoteModel(id: UUID(0), title: "Milk", subtitle: "Only fresh", isCompleted: false),
        NoteModel(id: UUID(1), title: "Bread", subtitle: nil, isCompleted: false),
        NoteModel(id: UUID(2), title: "Water", subtitle: "Only fresh", isCompleted: false),
        NoteModel(id: UUID(3), title: "Beer", subtitle: nil, isCompleted: false)
    ]

    static var mock: NonEmptyArray<PurchaseModel> = {

        return NonEmptyArray(PurchaseModel(id: UUID(0), notes: mockNotes, title: "My shopping list"))
    }()

    static func fabric() -> PurchaseModel {
        return PurchaseModel(id: UUID(),
                             notes: mockNotes,
                             title: "My shopping list \(UUID().uuidString.dropLast(10))")
    }
}
