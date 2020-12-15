import SwiftUI
import Firebase

@main
struct ScooterApp: App {
    
    init() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
