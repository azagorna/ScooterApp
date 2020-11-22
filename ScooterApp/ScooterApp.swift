//
//  ScooterAppApp.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 14/11/2020.
//

import SwiftUI
import Firebase

@main
struct ScooterApp: App {
    //let persistenceController = PersistenceController.shared
    
    init() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            RootView()
            //            CoreDateExampleView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
