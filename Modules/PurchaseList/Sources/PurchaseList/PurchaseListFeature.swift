//
//  NotesListFeature.swift
//  ShoppingList
//
//  Created by Max Tymchii on 25.09.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Models
import Note


public struct PurchaseListFeature: Reducer {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    @Dependency(\.dataManager) var dataManager

    public init() {}

    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var notes: IdentifiedArrayOf<NoteFeature.State> = []
        public var title: String = "Welcome"
        var inputText: MessageInputFeature.State

        public init(id: UUID,
                    notes: IdentifiedArrayOf<NoteFeature.State>,
                    title: String,
                    inputText: MessageInputFeature.State = MessageInputFeature.State()) {

            self.id = id
            self.notes = notes
            self.title = title
            self.inputText = inputText
        }

        public static func convert(from model: PurchaseModel) -> Self {
            return .init(id: model.id,
                         notes: .init(uniqueElements: model.notes.map(NoteFeature.State.convert(from:))),
                         title: model.title)
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case addNote(String)
        case binding(BindingAction<State>)
        case uncheckAll
        case notesAction(id: UUID, action: NoteFeature.Action)
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedNotes
        case inputTextAction(MessageInputFeature.Action)
    }

    enum CancelID {
        case noteCompletion
        case noteUncheckAll
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.inputText,
              action: /Action.inputTextAction) {
            MessageInputFeature()
        }

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
            case let .addNote(text):
                return addNewNote(with: text, state: &state)
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
            case let .inputTextAction(.tapOnActionButton(text)):
                return Effect<Action>.send(.addNote(text))
            case .inputTextAction:
                return .none
            }
        }
        .forEach(\.notes,
                  action: /Action.notesAction) {
            NoteFeature()
        }
    }

    private func addNewNote(with text: String, state: inout State) -> Effect<Action> {
        let note = NoteFeature.State(id: uuid(),
                                     title: text,
                                     subTitle: nil,
                                     status: .new)
        state.notes.append(note)
        return .send(.inputTextAction(.clearInput))
    }


    public static let demo: State = .init(id: UUID(), notes: [
        .demo
    ], title: "Demo Notes")

}
