//
//  File.swift
//  
//
//  Created by Max Tymchii on 28.10.2023.
//

import Foundation

public struct Emoji: Hashable {

    public let value: String
    public let name: String

    public init(value: String, name: String) {
        self.value = value
        self.name = name
    }

}
