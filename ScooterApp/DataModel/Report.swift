
import Foundation
import SwiftUI
import MapKit
import CoreLocation

//- `Hashable`
//    -
//- `Codable` (type alias for `encodable` and `decodable` combined)
//    - Useful for defining how a class, struct or enum should be translatable to/from other database structures such as JSON.
//- `Identifiable`
//    - Useful for uniquely identifying individual elements for a list (sometimes use KeyPaths like `\.id`)

enum ReportErrors: Error {
    case cantFindLocation(String)
    case cantFindAddress(String)
    case unknownError
}

class Report: NSObject, ObservableObject, Identifiable, MKAnnotation {
    
    //MKAnnotation required properties:
    var title: String? {getDayAsString() ?? "No day title"}
    var subtitle: String? {"Time: \(getTimeAsString() ?? "No time title")"}
    var coordinate: CLLocationCoordinate2D {CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)}
    
    private let locationManager = LocationManager.singleton
    private var dateFormatter = DateFormatter()
    var id: String = UUID().uuidString
    var photoFilename: String { get {self.id + ".jpg"} }
    var user: String = "Default" //Not used for now
    @Published var photo: UIImage?
    @Published var photoDownloadProgress = 0.0
    @Published var timestamp: Date? //Set when taking photo
    @Published var longitude: Double?
    @Published var latitude: Double?
    @Published var address: Address = .unknown
    @Published var qrCode: QRCode = .none
    @Published var brand: ScooterBrand = .none
    @Published var laying = false
    @Published var broken = false
    @Published var misplaced = false
    @Published var other = false
    @Published var comment = ""
    
    override init() {
        super.init()
    }
    
    convenience init(id: String, user: String, timestamp : Date, longitude: Double, latitude: Double, address: String, qrCode: String, laying: Bool, broken: Bool, misplaced: Bool, other: Bool, comment: String){
        self.init()
        self.user = user
        self.id = id
        self.photo = nil
        self.timestamp = timestamp
        self.longitude = longitude
        self.latitude = latitude
        self.setAddress(address)
        self.setQRCode(qrCode)
        self.laying = laying
        self.broken = broken
        self.misplaced = misplaced
        self.other = other
        self.comment = comment
    }
    
    func processPhoto() {
        guard let newPhoto = self.photo else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
            guard let self = self else {
                return
            }
            print("photo taken", newPhoto.debugDescription)
            
            let cropped = newPhoto.cropToSquare()
            print("photo cropped", cropped.debugDescription)
            
            let resized = cropped.resizeImage(newSize: CGSize(width: 512, height: 512))
            print("photo resized", resized.debugDescription)
            
            DispatchQueue.main.async { [weak self] in
                guard ((self?.photo = resized) != nil) else {
                    print("processPhoto() failed to save photo")
                    return
                }
                print("Photo was processed!")
            }
        }
    }
    
    func hasPhoto() -> Bool {
        return photo != nil
    }
    
    func setTimestamp() {
        self.timestamp = Date()
    }
    
    func setLocation() {
        // If the gps location can be found
        if let long = self.locationManager.lastLocation?.coordinate.longitude, let lat = locationManager.lastLocation?.coordinate.latitude {
            self.longitude = long
            self.latitude = lat
            
            // Try to find the address if longitude and latitude values are valid
            if long != 0.0 && lat != 0.0 {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long), completionHandler: { (places, error) in
                    if error == nil {
                        if let validPlaces = places {
                            
                            var addressDescriptions = [String]()
                            
                            if let street = validPlaces[0].name {
                                addressDescriptions.append(street)
                            }
                            if let postalCode = validPlaces[0].postalCode {
                                addressDescriptions.append(postalCode)
                            }
                            if let city = validPlaces[0].locality {
                                addressDescriptions.append(city)
                            }
                            if let country = validPlaces[0].country {
                                addressDescriptions.append(country)
                            }
                            
                            // Combine address pieces to string, seperated by commas
                            self.setAddress(addressDescriptions.joined(separator: ", "))
                            
                            // Uncomment to check various address outputs
                            //                            for place in validPlaces {
                            //                                print("place:",place)
                            //                                print("place.administrativeArea:", place.administrativeArea ?? "N/A")
                            //                                print("place.areasOfInterest:", place.areasOfInterest ?? "N/A")
                            //                                print("place.country:", place.country ?? "N/A")
                            //                                print("place.inlandWater:", place.inlandWater ?? "N/A")
                            //                                print("place.isoCountryCode:", place.isoCountryCode ?? "N/A")
                            //                                print("place.locality:", place.locality ?? "N/A")
                            //                                print("place.location:", place.location ?? "N/A")
                            //                                print("place.name:", place.name ?? "N/A")
                            //                                print("place.ocean:", place.ocean ?? "N/A")
                            //                                print("place.postalCode:", place.postalCode ?? "N/A")
                            //                                print("place.region:", place.region ?? "N/A")
                            //                                print("place.subAdministrativeArea:", place.subAdministrativeArea ?? "N/A")
                            //                                print("place.subLocality:", place.subLocality ?? "N/A")
                            //                                print("place.subThoroughfare:", place.subThoroughfare ?? "N/A")
                            //                                print("place.timeZone:", place.timeZone ?? "N/A")
                            //                            }
                        } else {
                            self.setAddress("Couldn't find address")
                        }
                    } else {
                        print("ERROR in setLocation() finding address:", error.debugDescription)
                        print("ERROR in setLocation() could not find address for:")
                        print("\tlongitude:", long)
                        print("\tlatitude:", lat)
                    }
                })
            }
        } else {
            print("Error: Report.setLocation() could not find location:" + locationManager.statusString)
            self.longitude = 0.0
            self.latitude = 0.0
        }
    }
    
    func setAddress(_ addr: String) {
        if addr.isEmpty {
            self.address = .unknown
        }
        self.address = .addr(addr)
    }
    
    func getAddressAsString() -> String {
        switch self.address {
            case .unknown:
                return "Unknown location"
            case .addr(let addr):
                return addr
        }
    }
    
    
    func setQRCode(_ url: String) {
        if url.isEmpty {
            self.qrCode = .none
        }
        self.qrCode = .url(url)
        detectBrandFromQRcode()
    }
    
    func hasQRcode() -> Bool {
        return self.qrCode != .none
    }
    
    func getQRcodeAsString() -> String {
        switch self.qrCode {
            case .none:
                return ""
            case .url(let url):
                return url
        }
    }
    
    private func detectBrandFromQRcode() {
        switch self.qrCode {
            case .url(let url):
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
                } else if (url.isEmpty){
                    self.brand = .none
                } else {
                    self.brand = .unknown
                }
            case .none:
                self.brand = .none
        }
    }
    
    func getBrandAsString() -> String {
        return self.brand.rawValue
    }
    
    func getViolationAsString() -> String {
        var violations = [String]()
        if laying {
            violations.append("Laying")
        }
        if broken {
            violations.append("Broken")
        }
        if misplaced {
            violations.append("Misplaced")
        }
        if other {
            violations.append("Other")
        }
        return violations.joined(separator: ", ")
    }
    
    func getDayAsString() -> String? {
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
        if let date = self.timestamp {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func getTimeAsString() -> String? {
        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeStyle = .short
        if let date = self.timestamp {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func hasViolation() -> Bool {
        self.laying || self.broken || self.misplaced || self.other
    }
    
    func checkIfSubmittable() -> Bool {
        if self.user.isEmpty || self.photo == nil || self.timestamp == nil || self.longitude == nil || self.latitude == nil {
            return false // No vital info must be missing
        } else if hasViolation() {
            return true // One description must be selected
        }
        return false
    }
    
}

enum ScooterBrand: String {
    case none = ""
    case unknown = "Unknown scooter brand"
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

enum Address: Equatable {
    case unknown
    case addr(String)
}
