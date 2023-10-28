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

        var inputField: MessageInputFeature.State
        @PresentationState public var scanPurchaseList: ScannerTCAFeature.State?
        @PresentationState public var draftList: DraftListFeature.State?

       public var purchaseModel: PurchaseModel {
            return  PurchaseModel(id: id,
                                  notes: notes
                .elements
                .map { NoteModel(id: $0.id,
                                 title: $0.title,
                                 subtitle: $0.subTitle,
                                 isCompleted: $0.status == .done) },
                                  title: title)
        }

        public enum Status: Equatable {
             case done
             case inProgress

            public var imageIconInverted: String {
                 switch self {
                 case .done:
                     return "circle"
                 case .inProgress:
                     return "checkmark.circle"
                 }
             }

             public var titleInverted: String {
                 switch self {
                 case .done:
                     return "Undone"
                 case .inProgress:
                     return "Mark as done"
                 }
             }

         }

        public init(id: UUID,
                    notes: IdentifiedArrayOf<NoteFeature.State>,
                    title: String,
                    inputText: MessageInputFeature.State = MessageInputFeature.State()) {

            self.id = id
            self.notes = notes
            self.title = title
            self.inputField = inputText
        }

        public static func convert(from model: PurchaseModel) -> Self {
            return .init(id: model.id,
                         notes: .init(uniqueElements: model.notes.map(NoteFeature.State.convert(from:))),
                         title: model.title)
        }

       public var status: Status {
           guard !notes.isEmpty else {
               return .inProgress
           }

            let inProgress = notes.filter { $0.status == .new }
            return inProgress.isEmpty ? .done : .inProgress
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
        case update(note: UUID, text: String)
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

        Scope(state: \.inputField,
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

            case let .inputTextAction(value):
                return inputTextAction(state: &state, action: value)

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
            case let .edit(id):
                let text = state.notes[id: id]?.title ?? ""
                state.inputField = MessageInputFeature.State(inputText: text, mode: .update(id))
                return .send(.inputTextAction(.activateTextField))
            case let .update(note: note, text: text):
                state.notes[id: note]?.title = text
                return .send(.inputTextAction(.clearInput))
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

    private func inputTextAction(state: inout State,
                                 action: MessageInputFeature.Action) -> Effect<Action> {
        switch action {
        case let .tapOnActionButton(text, mode):
            switch mode {
            case .create:
                return Effect<Action>.send(.addNote(text))
            case let .update(id):
                state.inputField = MessageInputFeature.State(inputText: "", mode: .create)
                return Effect<Action>.send(.update(note: id, text: text))
            }

        case .tapOnScannerButton:
            state.scanPurchaseList = ScannerTCAFeature.State()
            return .none

        default:
            return .none
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
        let model = state.purchaseModel

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

        let notes = TextSanitizer
            .sanitize(text)
            .compactMap {
            NoteFeature.State(id: uuid(),
                                        title: $0,
                                        subTitle: nil,
                                        status: .new)
        }

        state.notes.insert(contentsOf: notes, at: 0)
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
