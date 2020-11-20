//
//  ScooterAppApp.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 14/11/2020.
//

import SwiftUI

@main
struct ScooterApp: App {
    //let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
            //            CoreDateExampleView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
