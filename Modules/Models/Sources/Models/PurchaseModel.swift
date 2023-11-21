//
//  File.swift
//  
//
//  Created by Max Tymchii on 10.10.2023.
//

import Foundation

public struct EmojisDB {
    static let emojis =
    ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌",
     "🍉", "🍇", "🍓", "🍈", "🍒", "🍑",
     "🍍", "🥥", "🥝", "🍅", "🍆", "🥑",
     "🥦", "🥒", "🌶", "🌽", "🥕", "🥔",
     "🍠", "🥐", "🍞", "🥖", "🥨", "🧀",
     "🥚", "🍳", "🥞", "🥓", "🥩", "🍗",
     "🍖", "🌭", "🍔", "🍟", "🍕", "🥪",
     "🥙", "🌮", "🌯", "🥗", "🥘", "🥫",
     "🍝", "🍜", "🍲", "🍛", "🍣", "🍱",
     "🥟", "🍤", "🍙", "🍚", "🍘", "🍥",
     "🥠", "🍧", "🍨", "🍦", "🥧", "🍰",
     "🎂", "🍮", "🍭", "🍬", "🍫", "🍿",
     "🍩", "🍪", "🌰", "🥜", "🍯", "🥛",
     "🍼", "☕️", "🍵", "🥤", "🍶", "🍺",
     "🍻", "🥂", "🍷", "🥃", "🍸", "🍹",
     "🍾", "🥄", "🍴", "🍽", "🥣", "🥡"]

    public static func randomEmoji() -> String {
        let random = Int.random(in: 0..<emojis.count)
        return emojis[random]
    }
}

public struct PurchaseModel: Codable, Identifiable {

    public enum Status: Equatable {
        case done
        case inProgress
    }

    public let id: UUID
    public var emojiIcon: String
    public let notes: [NoteModel]
    public var title: String

    public var doneNotesCount: Int {
        return notes.filter(\.isCompleted).count
    }

    public var totalNotesCount: Int {
        return notes.count
    }

    public var status: Status {
        return totalNotesCount == doneNotesCount && !notes.isEmpty ? .done : .inProgress
    }

    public init(id: UUID, emojiIcon: String, notes: [NoteModel], title: String) {
        self.id = id
        self.emojiIcon = emojiIcon
        self.notes = notes
        self.title = title
    }

    public static func newPurchase(title: String) -> Self {
        return .init(id: UUID(), emojiIcon: EmojisDB.randomEmoji(), notes: [], title: title)
    }

    public func duplicate(uuid: UUID = .init()) -> Self {
        return .init(id: uuid, emojiIcon: emojiIcon, notes: notes, title: title)
    }

   public func shareVersion() -> String {
       return notes.reduce(title + "\n") { result, note in
           return result + note.title + " " + note.isCompleted.emoji + "\n"
       }
    }

}
