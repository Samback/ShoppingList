//
//  NotesListFeature.swift
//  ShoppingList
//
//  Created by Max Tymchii on 25.09.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Note

public extension IdentifiedArray where ID == NoteFeature.State.ID, Element == NoteFeature.State {
    static let mock: Self = [
        NoteFeature.State(id: UUID(1),
                          title: "Milk",
                          subTitle: nil,
                          status: .new),
        NoteFeature.State(id: UUID(2),
                          title: "Bread",
                          subTitle: "2 items",
                          status: .new),
        NoteFeature.State(id: UUID(4),
                          title: "Chockolate",
                          subTitle: nil,
                          status: .new),
        NoteFeature.State(id: UUID(5),
                          title: "Chees",
                          subTitle: "200 gr.",
                          status: .new),
        NoteFeature.State(id: UUID(6),
                          title: "Sprite",
                          subTitle: "1 L.",
                          status: .new),

    ]
}

public struct PurchaseListFeature: Reducer {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid

    public init() {}

    public struct State: Equatable, Identifiable {
       public let id: UUID
       public var notes: IdentifiedArrayOf<NoteFeature.State> = []
       public var title: String = "Welcome"

        public init(id: UUID, notes: IdentifiedArrayOf<NoteFeature.State>, title: String) {
            self.id = id
            self.notes = notes
            self.title = title
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case addNote
        case binding(BindingAction<State>)
        case uncheckAll
        case notesAction(id: UUID, action: NoteFeature.Action)
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedNotes
    }

    enum CancelID {
        case noteCompletion
        case noteUncheckAll
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .uncheckAll:
                state.notes.indices.forEach {
                    state.notes[$0].status = .new
                }
                return .run { send in
                    try await self.clock.sleep(for: .seconds(0.3))
                    await send(.sortCompletedNotes)
                }
                .cancellable(id: CancelID.noteUncheckAll, cancelInFlight: true)

            case .notesAction(id: _, action: .binding(\.$status)):
                return .run { send in
                    try await self.clock.sleep(for: .seconds(0.3))
                    await send(.sortCompletedNotes,
                               animation: Animation.easeInOut(duration: 0.5))
                }
                .cancellable(id: CancelID.noteCompletion, cancelInFlight: true)
            case .addNote:
                return .none
            case let .delete(index):
                state.notes.remove(atOffsets: index)
                return .none
            case let .move(source, destination):
                state.notes.move(fromOffsets: source, toOffset: destination)
                return .run { send in
                  try await self.clock.sleep(for: .milliseconds(500))
                  await send(.sortCompletedNotes)
                }

            case .sortCompletedNotes:
                state.notes.sort { first, second in
                    first.status == .new && second.status == .done
                }
                return .none

            case .notesAction:
                return .none
            }
        }
        .forEach(\.notes,
                  action: /Action.notesAction) {
            NoteFeature()
        }
    }

    public static let demo: State = .init(id: UUID(0), notes: [
        .demo
    ], title: "Demo Notes")

}
