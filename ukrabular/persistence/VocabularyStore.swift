//
//  VocabularyStore.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI
import Combine

final class WordStore: ObservableObject {
    @Published var words: [WordPair] = [] {
        didSet { save() }
    }

    private let filename = "wordpairs.json"
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    init() {
        self.load()
        if words.isEmpty {
            words = [
                WordPair(german: "Hallo", ukrainian: "Привіт"),
                WordPair(german: "Danke", ukrainian: "Дякую"),
                WordPair(german: "Bitte", ukrainian: "Будь ласка")
            ]
        }
    }

    func add(german: String, ukrainian: String) {
        let trimmedG = german.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedU = ukrainian.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedG.isEmpty && !trimmedU.isEmpty else { return }
        words.append(WordPair(german: trimmedG, ukrainian: trimmedU))
    }

    func remove(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(words)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            words = try JSONDecoder().decode([WordPair].self, from: data)
        } catch {
            // ignore - file might not exist yet
            print("Load error (if new app this is expected): \(error)")
        }
    }
}
