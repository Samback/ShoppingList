//
//  File.swift
//  
//
//  Created by Max Tymchii on 23.10.2023.
//

import Foundation


extension Character {
    var isValid: Bool {
        return isLetter || isNumber
    }
}

extension Array where Element == String {
    func cleanAlphaNumericWords() -> [String] {
        guard let text = first else {
            return self
        }

        do {
            let regex = try NSRegularExpression(pattern: #"(?<!\()\b\w+\)(?!\w+)"#)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            return matches.isEmpty ? self : self.dropFirst().map { String($0) }
                .cleanAlphaNumericWords()
        } catch {
            return self
        }
    }
}


public struct TextSanitizer {

    static func cleanLeadingInvalidCharacters(_ inputString: String) -> String {
        if let firstCharacter = inputString.first,
           !firstCharacter.isValid {
            return cleanLeadingInvalidCharacters(String(inputString.dropFirst()))
        }
        return inputString
    }

    public static func sanitize(_ text: String) -> [String] {
        sanitize(text
            .split(whereSeparator: \.isNewline)
            .compactMap(String.init))
    }

    public static func sanitize(_ texts: [String]) -> [String] {
        texts
            .compactMap { $0
                // Remove leading and trailing whitespace
                .split(whereSeparator: \.isWhitespace)
                    .joined(separator: " ")
                }
            .compactMap( cleanLeadingInvalidCharacters )
            .map { $0
                .split(whereSeparator: \.isWhitespace)
                    .map(String.init)
                    .cleanAlphaNumericWords()
                    .joined(separator: " ")
                }
    }
}
