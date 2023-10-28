//
//  UserModel.swift
//
//
//  Created by Max Tymchii on 28.10.2023.
//

import Foundation

public struct AccountModel: Codable, Equatable {
    public var list: [UUID]

    public init(list: [UUID]) {
        self.list = list
    }
}
