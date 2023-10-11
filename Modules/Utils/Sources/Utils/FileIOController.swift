//
//  File.swift
//
//
//  Created by Max Tymchii on 11.10.2023.
//

import Foundation
import Models

struct FileIOController {
    private let nestedFolderName = "ShoppingList"
    private var manager = FileManager.default

    func write<T: Encodable>(
        _ object: T,
        toDocumentNamed documentName: String,
        encodedUsing encoder: JSONEncoder = .init()
    ) throws {
        let fileURL = try documentURL(for: documentName)
        let data = try encoder.encode(object)
        try data.write(to: fileURL)
    }

    func readAll<T: Decodable>(decodedUsing decoder: JSONDecoder = .init()) throws -> [T] {
        try readAllFiles()
            .compactMap { url in
                try read(fromDocumentURL: url, decodedUsing: decoder)
            }
    }

    func delete(document name: String) throws {
        let documentURL = try documentURL(for: name)
        try manager.removeItem(at: documentURL)
    }

    func update<T: Codable>(document name: String, object: T) throws {
        let documentURL = try documentURL(for: name)
        try write(object, toDocumentNamed: name)
    }

    func readAllFiles() throws -> [URL]{
        let nestedFolderURL = try nestedFolderURL()
        return try FileManager.default.urls(for: nestedFolderURL)
    }

    func read<T: Decodable>(
        fromDocumentURL documentURL: URL,
        decodedUsing decoder: JSONDecoder = .init()
    ) throws -> T {
        let data = try Data(contentsOf: documentURL)
        return try decoder.decode(T.self, from: data)
    }

    private func documentURL(for documentName: String) throws -> URL {
        return try nestedFolderURL().appendingPathComponent(documentName)
    }

    private func nestedFolderURL() throws -> URL {
        let rootFolderURL = try manager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let nestedFolderURL = rootFolderURL.appendingPathComponent(nestedFolderName)

        if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
            try manager.createDirectory(
                at: nestedFolderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return nestedFolderURL
    }

}


extension PurchaseModel {
    static func fabric() -> PurchaseModel {
        let notes = [
            NoteModel(id: UUID(0), title: "Milk", subtitle: "Only fresh", isCompleted: false),
            NoteModel(id: UUID(1), title: "Bread", subtitle: nil, isCompleted: false),
            NoteModel(id: UUID(2), title: "Water", subtitle: "Only fresh", isCompleted: false),
            NoteModel(id: UUID(3), title: "Beer", subtitle: nil, isCompleted: false)
        ]
        return PurchaseModel(id: UUID(),
                             notes: notes,
                             title: "My shopping list \(UUID().uuidString.dropLast(10))")
    }
}

