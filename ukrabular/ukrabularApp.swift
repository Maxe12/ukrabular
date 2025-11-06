//
//  ukrabularApp.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 06.11.25.
//

import SwiftUI

// MARK: - App Entry
@main
struct UkrainianBuddyApp: App {
    @StateObject private var store = WordStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
