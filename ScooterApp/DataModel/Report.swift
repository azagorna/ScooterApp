
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
    let id: String
    var photoFilename: String { get {self.id + ".jpg"} }
    var photoThumbnailFilename: String { get {self.id + "-thump.jpg"} }
    let user: String //Not used for now
    @Published var photo: UIImage?
    @Published var timestamp: Date? //Set when taking photo
    @Published var longitude: Double?
    @Published var latitude: Double?
    @Published var qrCode: QRCode = .none
    @Published var brand: ScooterBrand = .none
    @Published var laying = false
    @Published var broken = false
    @Published var misplaced = false
    @Published var other = false
    @Published var comment = ""
    
    init() {
        self.user = "Default"
        self.id = UUID().uuidString
    }
    
    init(id: String, user: String, timestamp : Date, longitude: Double, latitude: Double, qrCode: String, laying: Bool, broken: Bool, misplaced: Bool, other: Bool, comment: String){
        self.id = id
        self.user = user
        self.photo = nil
        self.timestamp = timestamp
        self.longitude = longitude
        self.latitude = latitude
        self.setQRCode(qrCode)
        self.laying = laying
        self.broken = broken
        self.misplaced = misplaced
        self.other = other
        self.comment = comment
    }
    
    func hasPhoto() -> Bool {
        return photo != nil
    }
    
    func setTimestamp() {
        self.timestamp = Date()
    }
    
    func setLocation() {
        if let long = self.locationManager.lastLocation?.coordinate.longitude, let lat = locationManager.lastLocation?.coordinate.latitude {
            self.longitude = long
            self.latitude = lat
        } else {
            print("Error: Report.setLocation() could not find location:" + locationManager.statusString)
        }
    }
    
    func setQRCode(_ url: String) {
        if url.isEmpty {
            self.qrCode = .none
        }
        self.qrCode = .url(url)
        setBrand()
    }
    
    func hasQRcode() -> Bool {
        return self.qrCode == .none
    }
    
    func getQRcodeAsString() -> String {
        switch self.qrCode {
            case .none:
                return ""
            case .url(let url):
                return url
        }
    }
    
    func setBrand() {
        switch self.qrCode {
            case .url(let url):
                if (url.contains("li.me")) {
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
            case .none:
                self.brand = .none
        }
    }
    
    func getBrandAsString() -> String {
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

enum QRCode: Equatable {
    case none
    case url(String)
}
