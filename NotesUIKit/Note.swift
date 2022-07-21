// Note.swift

import UIKit

class Note: NSObject, Codable {
    var id: String = UUID().uuidString
    var text: String = ""

    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
