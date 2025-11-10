//
//  AddCategory.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 10.11.25.
//

import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject private var store: VocabularyStore
    @Binding var isPresented: Bool

    @State private var categoryName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kategroie")) {
                    TextField("z. B. Raum beschreiben", text: $categoryName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Add word pair")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addGroup(name: categoryName)
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
