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
            MainView()
            //            CoreDateExampleView()
            //                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
