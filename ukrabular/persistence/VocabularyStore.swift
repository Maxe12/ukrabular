//
//  VocabularyStore.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI
import Combine

final class VocabularyStore: ObservableObject {
    @Published var vocabularyGroups: [VocabularyGroup] = [] {
        didSet { save() }
    }

    private let filename = "wordpairs.json"
    private var persistenceService: PersistenceService

    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        load()
        if vocabularyGroups.isEmpty {
            seedDefaults()
        }
    }
    
    private func seedDefaults() {
        let greetings = [
            WordPair(german: "Hallo", ukrainian: "Привіт"),
            WordPair(german: "Danke", ukrainian: "Дякую"),
            WordPair(german: "Bitte", ukrainian: "Будь ласка")
        ]
        vocabularyGroups.append(VocabularyGroup(wordPairs: greetings, categoryName: "Begrüßung"))
        let initialRoom = [
            WordPair(german: "Fenster", ukrainian: "Вікно")
        ]
        vocabularyGroups.append(VocabularyGroup(
            wordPairs: initialRoom, categoryName: "Raum Beschreiben"
        ))
    }

    func addGroup(name: String) {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            vocabularyGroups.append(VocabularyGroup(wordPairs: [], categoryName: trimmed))
        }
        
    func addWord(to groupID: UUID, german: String, ukrainian: String) {
        let trimmedG = german.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedU = ukrainian.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedG.isEmpty && !trimmedU.isEmpty else { return }
        
        if let index = vocabularyGroups.firstIndex(where: { $0.id == groupID }) {
            vocabularyGroups[index].wordPairs.append(
                WordPair(german: trimmedG, ukrainian: trimmedU)
            )
        }
    }
    
    func removeGroup(at offsets: IndexSet) {
        vocabularyGroups.remove(atOffsets: offsets)
    }
    
    func removeWord(from groupID: UUID, at offsets: IndexSet) {
        if let index = vocabularyGroups.firstIndex(where: { $0.id == groupID }) {
            vocabularyGroups[index].wordPairs.remove(atOffsets: offsets)
        }
    }
    
    private func save() {
        persistenceService.save(vocabularyGroups, to: filename)
    }

    private func load() {
        if let loaded: [VocabularyGroup] = persistenceService.load([VocabularyGroup].self, from: filename) {
            vocabularyGroups = loaded
        }
    }
}
