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
import Theme
import Tips

extension PurchaseModel.Status {

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

public struct PurchaseListFeature: Reducer {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.userDefaultsManager) var userDefaultsManager
    @Dependency(\.counterManager) var counterManager

    public init() {}

    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var emojiIcon: String
        public var notes: IdentifiedArrayOf<NoteFeature.State> = []
        public var title: String = "Welcome"

        var activityView: UIView?

        public var inputField: MessageInputFeature.State
        @PresentationState public var scanPurchaseList: ScannerFeature.State?
        @BindingState public var viewMode: ViewMode = .expand
        @PresentationState public var confirmationDialog: ConfirmationDialogState<Action.ContextMenuAction>?

        public var purchaseModel: PurchaseModel {
            return  PurchaseModel(id: id,
                                  emojiIcon: emojiIcon,
                                  notes: notes
                .elements
                .map { NoteModel(id: $0.id,
                                 title: $0.title,
                                 isCompleted: $0.status == .done) },
                                  title: title)
        }

        public var counter: CounterView.Counter {
            return .init(current: purchaseModel.doneNotesCount,
                         total: purchaseModel.totalNotesCount)
        }

        public enum ViewMode {
            case compact
            case expand

            var invertedValue: Self {
                switch self {
                case .compact:
                    return .expand
                case .expand:
                    return .compact
                }
            }

            var image: Image {
                switch self {
                case .compact:
                    return Image(.compact)
                case .expand:
                    return Image(.expand)
                }
            }

            var height: CGFloat {
                switch self {
                case .compact:
                    return 52
                case .expand:
                    return 68
                }

            }
        }

        public init(id: UUID,
                    emojiIcon: String,
                    notes: IdentifiedArrayOf<NoteFeature.State>,
                    title: String,
                    inputText: MessageInputFeature.State = MessageInputFeature
            .State(inputText: "",
                   mode: .create(.purchaseList))) {

            self.id = id
            self.emojiIcon = emojiIcon
            self.notes = notes
            self.title = title
            self.inputField = inputText
        }

        public static func convert(from model: PurchaseModel) -> Self {
            return .init(id: model.id,
                         emojiIcon: model.emojiIcon,
                         notes: .init(uniqueElements: model.notes.map(NoteFeature.State.convert(from:))),
                         title: model.title)
        }

    }

    public enum Action: BindableAction, Equatable {

        case addNote(String)
        case binding(BindingAction<State>)
        case checkAll
        case delete(IndexSet)
        case showConfirmationDialog(UUID)

        case delegate(Delegate)
        public enum Delegate: Equatable {
            case update(State)
        }
        case onAppear

        case inputTextAction(MessageInputFeature.Action)
        case notesAction(id: UUID, action: NoteFeature.Action)
        case move(IndexSet, Int)
        case scannerAction(PresentationAction<ScannerFeature.Action>)
        case sortCompletedNotes
        case saveUpdatesAtList

        case tapOnResizeButton
        case uncheckAll
        case update(note: UUID, text: String)
        case contextMenuAction(ContextMenuAction)
        case updateCounter

        public enum ContextMenuAction: Equatable {
            case edit(UUID)
            case duplicate(UUID)
            case deleteNote(UUID)
        }

        case confirmationDialog(PresentationAction<Action.ContextMenuAction>)
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
            case .notesAction(id: _, action: .binding(\.$status)):
                return notesAction()

            case .onAppear:
                state.viewMode = userDefaultsManager.listStateExpanded() ? .expand : .compact
                return .none

            case let .addNote(text):
                return addNewNote(with: text, state: &state)

            case let .delete(index):
                state.notes.remove(atOffsets: index)
                return saveUpdates(state: &state)

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

            case .tapOnResizeButton:
                state.viewMode = state.viewMode.invertedValue
                userDefaultsManager.setListStateExpanded(state.viewMode == .expand)
                return .none

            case .uncheckAll:
                return uncheckedAll(state: &state)

            case .checkAll:
                return checkAll(state: &state)
            case let .update(note: note, text: text):
                state.notes[id: note]?.title = text
                return .send(.inputTextAction(.clearInput))
            case .binding:
                return .none

            case let .contextMenuAction(localAction):
                return contextMenuActions(state: &state, action: localAction)
            case let .showConfirmationDialog(id):
                state.confirmationDialog = ConfirmationDialogState(title: {
                    TextState("")
                }, actions: {
                    return [ ButtonState(action: .edit(id)) {
                                             TextState("Edit")
                                         },
                                         ButtonState(action: .duplicate(id)) {
                                             TextState("Duplicate")
                                         },
                                         ButtonState(role: .destructive,
                                                     action: .deleteNote(id)) {
                                                         TextState("Delete")
                                         }]
                }
                )
                return .none
            case let .confirmationDialog(localAction):
                return confirmationDialog(state: &state, action: localAction)
            case .updateCounter:
                counterManager.updateCounter(state.counter)
                return .none
            }

        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
        .ifLet(\.$scanPurchaseList,
                action: /Action.scannerAction, destination: {
                    ScannerFeature()
        })
        .forEach(\.notes,
                  action: /Action.notesAction) {
            NoteFeature()
        }

    }

    private func confirmationDialog(state: inout State, action: PresentationAction<Action.ContextMenuAction>) -> Effect<Action> {
        switch action {
        case .dismiss:
            return .none
        case let .presented(localAction):
            return contextMenuActions(state: &state, action: localAction)
        }
    }

    private func contextMenuActions(state: inout State,
                                    action: Action.ContextMenuAction) -> Effect<Action> {
        switch action {
        case let .duplicate(id):
            guard let title = state.notes[id: id]?.title else {
                return .none
            }

            return
                .run { send in
                    try await self.clock.sleep(for: .seconds(0.3))
                    await send(.addNote(title))
                    await send(.updateCounter)
                }

        case let .deleteNote(id):
            state.notes.remove(id: id)
            return .run { send in
                await send(.updateCounter)
                await send(.saveUpdatesAtList)
            }
        case let .edit(id):
            let text = state.notes[id: id]?.title ?? ""
            state.inputField = MessageInputFeature.State(inputText: text, mode: .update(id, .purchaseList))
            return .send(.inputTextAction(.activateTextField))
        }
    }

    private func inputTextAction(state: inout State,
                                 action: MessageInputFeature.Action) -> Effect<Action> {
        switch action {
        case let .tapOnActionButton(text, mode):
            switch mode {
            case .create:
                return Effect<Action>.send(.addNote(text))
            case let .update(id, _):
                state.inputField = MessageInputFeature.State(inputText: "", mode: .create(.purchaseList))
                return Effect<Action>.send(Action.update(note: id, text: text))
            }

        case .tapOnScannerButton:
            state.scanPurchaseList = ScannerFeature.State()
            return .none

        default:
            return .none
        }
    }

    private func scannerActionsAggregator(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .scannerAction(.presented(.binding(\ScannerFeature.State.$texts))):
            let adoptedString = state.scanPurchaseList?.texts.joined(separator: "\n") ?? ""
            state.scanPurchaseList = nil
            return .send(.addNote(adoptedString))
        case .scannerAction(.presented(.binding(\ScannerFeature.State.$isPresented))):
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
                                        status: .new)
        }

        state.notes.insert(contentsOf: notes, at: 0)
        return .run { send in
//            await ChangeOrderTip.counter.donate()
            await send(.updateCounter)
            await send(.sortCompletedNotes)
            await send(.inputTextAction(.clearInput))
        }
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
            await send(.updateCounter)
            try await self.clock.sleep(for: .seconds(0.3))
            await send(.sortCompletedNotes,
                       animation: Animation.easeInOut(duration: 0.5))
        }
        .cancellable(id: CancelID.noteCompletion, cancelInFlight: true)
    }

    public static let demo: State = .init(id: UUID(),
                                          emojiIcon: EmojisDB.randomEmoji(),
                                          notes: [
        .demo,
        .init(id: UUID(), title: "Vine", status: .new)
    ], title: "Demo")

}
