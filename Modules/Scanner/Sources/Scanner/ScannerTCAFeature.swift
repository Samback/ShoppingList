//
//  File.swift
//
//
//  Created by Max Tymchii on 16.10.2023.
//

import Foundation
import Combine
import ComposableArchitecture
import UIKit

public struct ScannerTCAFeature: Reducer {

    @Dependency(\.recognitionService) var recognitionService

    public struct State: Equatable {
    }

    public enum Action {
        case initialLoad(publisher: PassthroughSubject<ScannerView.Action, Never>)
        case delegate(Delegate)
        public enum Delegate {
            case canceled
            case closed
            case error(Error)
            case texts(TaskResult<[String]>)
        }

        case receivedImages([UIImage])
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .initialLoad(publisher):
                return subscribeOnEvents(actionPublisher: publisher)
            case .delegate:
                return .none
            case let .receivedImages(images):
                return recogniseText(at: images)
            }
        }
    }

    private func recogniseText(at images: [UIImage]) -> Effect<Action> {
        return .run { send in
            await send(
                .delegate(
                    .texts(
                        await TaskResult {
                            await recognitionService.recognizeText(images)
                        }
                    )
                )
            )
        }
    }

    private func subscribeOnEvents(actionPublisher: PassthroughSubject<ScannerView.Action, Never>) -> Effect<Action> {
        return Effect<Action>
            .publisher {
                actionPublisher.map { action in
                    switch action {
                    case let .result(images):
                        return .receivedImages(images)
                    case .cancel:
                        return .delegate(.canceled)
                    case let .error(error):
                        return .delegate(.error(error))
                    }
                }
            }
    }
}
