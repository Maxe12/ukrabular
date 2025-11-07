//
//  WordPair.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI

struct WordPair: Identifiable, Codable, Equatable {
    let id: UUID
    var german: String
    var ukrainian: String

    init(id: UUID = UUID(), german: String, ukrainian: String) {
        self.id = id
        self.german = german
        self.ukrainian = ukrainian
    }
}
