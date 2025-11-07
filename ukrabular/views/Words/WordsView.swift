//
//  WordsView.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject private var store: VocabularyStore
    let group: VocabularyGroup

    @State private var german = ""
    @State private var ukrainian = ""
    
    var body: some View {
        List {
            ForEach(group.wordPairs) { pair in
                VStack(alignment: .leading) {
                    Text(pair.german).font(.headline)
                    Text(pair.ukrainian).foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteWord)
        }
        .navigationTitle(group.categoryName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addWord) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func addWord() {
        // For now, a simple demo; ideally open a sheet to enter word
        store.addWord(to: group.id, german: "Test", ukrainian: "Тест")
    }
    
    private func deleteWord(at offsets: IndexSet) {
        store.removeWord(from: group.id, at: offsets)
    }
}
