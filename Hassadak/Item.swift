//
//  Item.swift
//  history
//
//  Created by Sumayah Alshehri on 02/09/1446 AH.
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
