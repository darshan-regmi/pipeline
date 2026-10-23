//
//  pipelineApp.swift
//  pipeline
//
//  Created by Darshan Regmi on 01/11/2026.
//

import SwiftUI
import CoreData

@main
struct pipelineApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
