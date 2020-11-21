
import Foundation
import SwiftUI
import CoreLocation

//- `Hashable`
//    -
//- `Codable` (type alias for `encodable` and `decodable` combined)
//    - Useful for defining how a class, struct or enum should be translatable to/from other database structures such as JSON.
//- `Identifiable`
//    - Useful for uniquely identifying individual elements for a list (sometimes use KeyPaths like `\.id`)

enum ReportErrors: Error {
    case cantFindLocation(String)
    case unknownError
}

extension Report: Hashable {
    static func == (lhs: Report, rhs: Report) -> Bool { lhs.id == rhs.id } // Equatable
    func hash(into hasher: inout Hasher) { hasher.combine(self.id) }
}

class Report: Identifiable, ObservableObject {
    private let locationManager = LocationManager.singleton
    let id: UUID
    let user = "Default" //Not used for now
    @Published var photo: UIImage? { didSet {
        self.setTimestamp()
        do {
            try self.setLocation()
        } catch {
            print("Cant find location: \(error)")
        }        
    }}
    @Published var timestamp: Date? //Set when taking photo
    @Published var longitude: Double?
    @Published var latitude: Double?
    @Published var qrCode: String?
    @Published var brand: ScooterBrand = .none
    @Published var laying = false
    @Published var broken = false
    @Published var misplaced = false
    @Published var other = false
    @Published var comment = ""
    
    init() {
        self.id = UUID()
    }
    
    func hasPhoto() -> Bool {
        return photo != nil
    }
    
    func setTimestamp() {
        self.timestamp = Date()
    }
    
    func setLocation() throws {
        if let long = self.locationManager.lastLocation?.coordinate.longitude, let lat = locationManager.lastLocation?.coordinate.latitude {
            self.longitude = long
            self.latitude = lat
        } else {
            throw ReportErrors.cantFindLocation("setLocation() could not find location:" + locationManager.statusString)
        }
    }
    
    func setQRCodeAndBrand(_ url: String) {
        self.qrCode = url
        if (url.contains("lime")) {
            self.brand = .lime
        } else if (url.contains("tier")) {
            self.brand = .tier
        } else if (url.contains("bird")) {
            self.brand = .bird
        } else if (url.contains("wind")) {
            self.brand = .wind
        } else if (url.contains("circ")) {
            self.brand = .circ
        } else {
            self.brand = .none
        }
    }
    
    func hasQRcode() -> Bool {
        return qrCode != nil && !qrCode!.isEmpty
    }
    
    func getBrandName() -> String {
        return self.brand.rawValue
    }
    
    func checkIfSubmittable() -> Bool {
        if self.user.isEmpty || self.photo == nil || self.timestamp == nil || self.longitude == nil || self.latitude == nil {
            return false // No vital info must be missing
        } else if self.laying || self.broken || self.misplaced || self.other {
            return true // One description must be selected
        }
        return false
    }
    
}

enum ScooterBrand: String {
    case none = "Unknown"
    case lime = "Lime"
    case tier = "Tier"
    case bird = "Bird"
    case wind = "Wind"
    case circ = "Circ"
}
