//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.10.2023.
//

import Foundation

public struct NoteModel: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let subtitle: String?
    public var isCompleted: Bool

    public init(id: UUID, title: String, subtitle: String?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
    }
}
