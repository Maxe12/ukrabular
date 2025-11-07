//
//  WordList.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject private var store: WordStore
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(store.words) { word in
                    VStack(alignment: .leading) {
                        Text(word.german)
                            .font(.headline)
                        Text(word.ukrainian)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: store.remove)
            }
            .navigationTitle("Word Pairs")
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
            .sheet(isPresented: $showingAdd) {
                AddWordView(isPresented: $showingAdd)
                    .environmentObject(store)
            }
        }
    }
}

struct AddWordView: View {
    @EnvironmentObject private var store: WordStore
    @Binding var isPresented: Bool

    @State private var german = ""
    @State private var ukrainian = ""

    var body: some View {
        NavigationView {
            Form {
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
                        store.add(german: german, ukrainian: ukrainian)
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

struct WordListView_Previews: PreviewProvider {
    static var previews: some View {
        WordListView()
            .environmentObject(WordStore())
    }
}
