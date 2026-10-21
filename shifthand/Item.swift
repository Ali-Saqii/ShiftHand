//
//  Item.swift
//  shifthand
//
//  Created by Mac mini on 21/10/2026.
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
