//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.10.2023.
//

import Foundation

extension Bool {
    var emoji: String {
        return self ? "✅" : "❌"
    }
}

public struct NoteModel: Codable, Identifiable {
    public let id: UUID
    public var title: String
    public var subtitle: String?
    public var isCompleted: Bool

    public init(id: UUID, title: String, subtitle: String?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
    }
}
