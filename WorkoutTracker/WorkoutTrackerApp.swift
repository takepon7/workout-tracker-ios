//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//

import SwiftUI
import CoreData

@main
struct WorkoutTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(profileManager)
                .environmentObject(languageManager)
        }
    }
}
