//
//  WordList.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI

struct CategorysView: View {
    @EnvironmentObject private var store: VocabularyStore
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(store.vocabularyGroups) { group in
                    NavigationLink(destination: WordListView(group: group)) {
                    VStack(alignment: .leading) {
                        Text(group.categoryName)
                            .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: store.removeGroup)
            }
            .navigationTitle("Kategorien")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add word pair")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }
}

/*
 .sheet(isPresented: $showingAdd) {
     AddWordView(isPresented: $showingAdd)
         .environmentObject(store)
 }

*/
 
struct CategorysView_Previews: PreviewProvider {
    static var previews: some View {
        CategorysView()
            .environmentObject(VocabularyStore())
    }
}
