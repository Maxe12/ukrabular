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
 
struct AddWordView: View {
    @EnvironmentObject private var store: WordStore
    @Binding var isPresented: Bool

    @State private var category = ""
    @State private var german = ""
    @State private var ukrainian = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group")) {
                    TextField("e.g. Basics, Food, Travel", text: $category)
                }
                Section(header: Text("German")) {
                    TextField("z. B. Haus", text: $german)
                        .autocapitalization(.words)
                }
                Section(header: Text("Ukrainian")) {
                    TextField("Наприклад: дім", text: $ukrainian)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Add word pair")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(german: german, ukrainian: ukrainian, category: category)
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
*/
 
struct CategorysView_Previews: PreviewProvider {
    static var previews: some View {
        CategorysView()
            .environmentObject(VocabularyStore())
    }
}
