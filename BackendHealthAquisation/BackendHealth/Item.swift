//
//  Item.swift
//  BackendHealth
//
//  Created by Carlos Paredes on 6/12/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
