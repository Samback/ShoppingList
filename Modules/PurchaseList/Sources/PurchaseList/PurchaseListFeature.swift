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
import Scanner
import Analytics
import ComposableAnalytics

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
        @PresentationState public var scanPurchaseList: ScannerTCAFeature.State?
        @PresentationState public var draftList: DraftListFeature.State?

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

    public enum Action: BindableAction, Equatable {
        case addNote(String)
        case binding(BindingAction<State>)
        case checkAll
        case duplicate(UUID)
        case delete(IndexSet)
        case deleteNote(UUID)
        case draftListAction(PresentationAction<DraftListFeature.Action>)

        case delegate(Delegate)
        public enum Delegate: Equatable {
            case update(State)
        }

        case edit(UUID)
        case inputTextAction(MessageInputFeature.Action)
        case notesAction(id: UUID, action: NoteFeature.Action)
        case move(IndexSet, Int)
        case scannerAction(PresentationAction<ScannerTCAFeature.Action>)
        case sortCompletedNotes
        case saveUpdatesAtList
        case uncheckAll
    }

    enum CancelID {
        case noteCompletion
        case noteUncheckAll
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        AnalyticsReducer { _, action in
            switch action {
            case let .addNote(note):
                return .event(name: "AddNewNote", properties: ["title": note])
            default:
                return nil
            }
        }

        Scope(state: \.inputText,
              action: /Action.inputTextAction) {
            MessageInputFeature()
        }

        Reduce { state, action in

            switch action {
            case .binding:
                return .none
            case .notesAction(id: _, action: .binding(\.$status)):
                return notesAction()

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
                state.notes.sort { $0.status == .new && $1.status == .done }
                return saveUpdates(state: &state)

            case .notesAction:
                return .none

            case let .inputTextAction(.tapOnActionButton(text)):
                return Effect<Action>.send(.addNote(text))

            case .inputTextAction(.tapOnScannerButton):
                state.scanPurchaseList = ScannerTCAFeature.State()
                return .none

            case .inputTextAction:
                return .none

            case .saveUpdatesAtList:
                return saveUpdates(state: &state)

            case .delegate:
                return .none

            case .scannerAction:
                return scannerActionsAggregator(state: &state, action: action)

            case .draftListAction:
                return draftListActionsAggregator(state: &state, action: action)

            case .uncheckAll:
                return uncheckedAll(state: &state)
            case .checkAll:
                return checkAll(state: &state)
            case let .duplicate(id):
                guard let title = state.notes[id: id]?.title else {
                    return .none
                }

                return
                    .run { send in
                        try await self.clock.sleep(for: .seconds(0.3))
                        await send(.addNote(title))
                    }

            case let .deleteNote(id):
                state.notes.remove(id: id)
                return .none
            case .edit(_):
                return .none
            }

        }
        .ifLet(\.$scanPurchaseList,
                action: /Action.scannerAction, destination: {
                    ScannerTCAFeature()
        })
        .ifLet(\.$draftList,
                action: /Action.draftListAction,
                destination: {
                    DraftListFeature()
        })
        .forEach(\.notes,
                  action: /Action.notesAction) {
            NoteFeature()
        }

    }

    private func draftListActionsAggregator(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .draftListAction(.presented(.delegate(.addNewShoppingNotes(newItems)))):
            state
                .notes
                .append(contentsOf: newItems
                    .map {
                        NoteModel(id: uuid(),
                                  title: $0,
                                  subtitle: nil,
                                  isCompleted: false)
                    }
                    .map(NoteFeature.State.convert(from:))
                )

            state.draftList = nil
            return .send(.sortCompletedNotes)

        case .draftListAction(.presented(.delegate(.cancel))):
            state.draftList = nil
            return .none

        default:
            return .none
        }
    }

    private func scannerActionsAggregator(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .scannerAction(.presented(.delegate(.texts(.success(texts))))):
            state.scanPurchaseList = nil
            let sanitized = TextSanitizer.sanitize(texts)
            state.draftList = DraftListFeature
                .State(rawList: sanitized)
            return .none
        case .scannerAction(.presented(.delegate(.canceled))):
            state.scanPurchaseList = nil
            return .none
        case .scannerAction(.presented(.delegate(.closed))):
            state.scanPurchaseList = nil
            return .none
        default:
            return .none
        }

    }

    private func saveUpdates(state: inout State) -> Effect<Action> {
        let notes = state.notes.map { NoteModel(id: $0.id,
                                                title: $0.title,
                                                subtitle: $0.subTitle,
                                                isCompleted: $0.status == .done) }
        let model = PurchaseModel(id: state.id,
                                  notes: notes,
                                  title: state.title)

        return Effect<Action>.merge(
            Effect<Action>.run { _ in
                await TaskResult {
                    try await self.dataManager.createDocument(model)
                }
            },
            Effect<Action>.send(.delegate(.update(state)))
        )

    }

    private func addNewNote(with text: String, state: inout State) -> Effect<Action> {
        guard !text.isEmpty else {
            return .none
        }

        let note = NoteFeature.State(id: uuid(),
                                     title: text,
                                     subTitle: nil,
                                     status: .new)

        state.notes.insert(note, at: 0)

        return Effect<Action>
            .merge(
                .send(.sortCompletedNotes),
                .send(.inputTextAction(.clearInput))
            )
    }

    private func uncheckedAll(state: inout State) -> Effect<Action> {
        state.notes.indices.forEach {
            state.notes[$0].status = .new
        }

        return .run { send in
            try await self.clock.sleep(for: .seconds(0.3))
            await send(.sortCompletedNotes)
        }
        .cancellable(id: CancelID.noteUncheckAll, cancelInFlight: true)
    }

    private func checkAll(state: inout State) -> Effect<Action> {
        state.notes.indices.forEach {
            state.notes[$0].status = .done
        }

        return .run { send in
            try await self.clock.sleep(for: .seconds(0.3))
            await send(.sortCompletedNotes)
        }
        .cancellable(id: CancelID.noteUncheckAll, cancelInFlight: true)
    }

    private func notesAction() -> Effect<Action> {
        return .run { send in
            try await self.clock.sleep(for: .seconds(0.3))
            await send(.sortCompletedNotes,
                       animation: Animation.easeInOut(duration: 0.5))
        }
        .cancellable(id: CancelID.noteCompletion, cancelInFlight: true)
    }

    public static let demo: State = .init(id: UUID(), notes: [
        .demo
    ], title: "Demo Notes")

}
