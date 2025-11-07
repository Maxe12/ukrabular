//
//  AddWord.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 08.11.25.
//

import SwiftUI

struct AddWordView: View {
    @EnvironmentObject private var store: VocabularyStore
    @Binding var isPresented: Bool
    
    let group: VocabularyGroup

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
                        store.addWord(to: group.id, german: german, ukrainian: ukrainian)
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
