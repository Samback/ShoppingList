//
//  File.swift
//  
//
//  Created by Max Tymchii on 11.10.2023.
//

import Foundation

public extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory = .documentDirectory, skipsHiddenFiles: Bool = true ) throws -> [URL] {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }

    func urls(for folderURL: URL, skipsHiddenFiles: Bool = true ) throws -> [URL] {
        try contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
    }
}
