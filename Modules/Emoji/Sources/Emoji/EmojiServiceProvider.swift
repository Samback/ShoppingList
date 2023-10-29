//
//  File.swift
//  
//
//  Created by Max Tymchii on 28.10.2023.
//

import Foundation
import Smile
import ComposableArchitecture

public struct EmojiServiceProvider {
    public var loadEmojis: @Sendable () -> [Emoji]
}

extension EmojiServiceProvider: DependencyKey {

    public static var liveValue: Self {
        return EmojiServiceProvider(loadEmojis: {
            return Smile
                .list()
                .map {
                    Emoji(value: $0, name: name(emoji: $0).first ?? "") }
        })
    }
}

public extension DependencyValues {
  var emojiServiceProvider: EmojiServiceProvider {
    get { self[EmojiServiceProvider.self] }
    set { self[EmojiServiceProvider.self] = newValue }
  }
}
