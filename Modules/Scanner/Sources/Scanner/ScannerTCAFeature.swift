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
import SwiftUI

public struct ScannerTCAFeature: Reducer {

    @Dependency(\.recognitionService) var recognitionService
    @Environment(\.scannerViewAction) var actionPublisher: PassthroughSubject<ScannerView.Action, Never>

    public init() {}

    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case initialLoad
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case canceled
            case closed
            case error
            case texts(TaskResult<[String]>)
        }

        case receivedImages([UIImage])
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .initialLoad:
                return subscribeOnEvents()
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

    private func subscribeOnEvents() -> Effect<Action> {
        return Effect<Action>
            .publisher {
                actionPublisher.map { action in
                    switch action {
                    case let .result(images):
                        return .receivedImages(images)
                    case .cancel:
                        return .delegate(.canceled)
                    case .error:
                        return .delegate(.error)
                    }
                }
            }
    }
}
