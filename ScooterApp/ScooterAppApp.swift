//
//  ScooterAppApp.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 14/11/2020.
//

import SwiftUI

@main
struct ScooterAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
