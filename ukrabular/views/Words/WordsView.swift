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
    @State private var showCreator = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(group.wordPairs) { pair in
                    VStack(alignment: .leading) {
                        Text(pair.ukrainian).font(.headline)
                        Text(pair.german).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(group.categoryName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreator = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add word pair")
                }
            }
        }
        .sheet(isPresented: $showCreator) {
             AddWordView(isPresented: $showCreator, group: group)
                 .environmentObject(store)
         }
    }
}


struct WordListView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VocabularyStore()
        let mockGroup = store.vocabularyGroups.first!
        
        WordListView(group: mockGroup)
            .environmentObject(VocabularyStore())
    }
}
