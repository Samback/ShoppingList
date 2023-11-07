//
//  File.swift
//  
//
//  Created by Max Tymchii on 06.11.2023.
//

import Foundation
import SwiftData

@Model
public class AppConfigurationModel: Identifiable {
    public let id: UUID
    public var isZoomOut: Bool

    public init(id: UUID = UUID(), isZoomOut: Bool) {
        self.id = id
        self.isZoomOut = isZoomOut
    }

}
