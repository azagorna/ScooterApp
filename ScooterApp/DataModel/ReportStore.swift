

import Firebase
import Foundation
import UIKit

class ReportStore{
    
    static let singleton = ReportStore()
    var reports = [String:Report]()
    var photos = [String:UIImage]()
    let placeholder: UIImage = UIImage(named: "placeholder_missing_scooter")!
    
    //Firebase Stuff
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let storageRef: StorageReference
    
    private init() {
        //Firebase Stuff
        self.storageRef = storage.reference()
    }
    
    func getReportsListByDate() -> [Report] {
        return Array(self.reports.values).sorted(by: {$0.timestamp!.compare($1.timestamp!).rawValue == 1})
    }
    
    func findPhoto(filename: String) -> UIImage {
        if let found = photos[filename] {
            return found
        }
        return placeholder
    }
    
    
    func uploadPhoto(image: UIImage, name: String) {
        
        // Create a file name for the image to be uploaded
        let filename = name
        
        // Create a reference to the file you want to upload
        let photoImagesRef = storageRef.child("report_images/" + filename)
        
        // UPLOAD FILE:
        // Data in memory
        let data: Data = image.jpegData(compressionQuality: 0.8)!
        
        // Create file metadata including the content type
        let jpegmeta = StorageMetadata()
        jpegmeta.contentType = "image/jpeg"
        
        // Upload the file
        photoImagesRef.putData(data, metadata: jpegmeta) { (metadata, error) in
            
            photoImagesRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }
    
    func uploadReport (report: Report) {
        // Add a new document with a generated ID
        db.collection("reports").addDocument(data: [
            "id": report.id,
            "user": report.user,
            "photoFilename" : report.photoFilename,
            "timestamp": Firebase.Date(timeIntervalSince1970: report.timestamp?.timeIntervalSince1970 ?? Date().timeIntervalSince1970),
            "geolocation": Firebase.GeoPoint(latitude: report.latitude ?? 0.0, longitude: report.longitude ?? 0.0),
            "qrCode": report.getQRcodeAsString(),
            "brand": report.getBrandAsString(),
            "laying": report.laying,
            "broken": report.broken,
            "misplaced": report.misplaced,
            "other": report.other,
            "comment": report.comment
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Report added with id: \(report.id)")
            }
        }
    }
    
    private func downloadPhoto(filename: String) {
        
        // Only download photo if it is not already downloaded
        if photos[filename] == nil {
            
            // Create a reference to the file you want to download
            let photoRef = storageRef.child("/report_images/" + filename)
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            photoRef.getData(maxSize: 10_000_000) { data, error in
                if error != nil {
                    // Uh-oh, an error occurred!
                    print()
                    print("Error in ReportStore.downloadPhoto()! No image was returned")
                    print("report_images/" + filename)
                    print("Error: \(error.debugDescription)")
                    print()
                    
                } else {
                    // Data is returned
                    self.photos[filename] = UIImage(data: data!)
                    print("\(filename) added to downloaded photos")
                }
            }
        } else {
            print("\(filename) was already in downloaded photos")
        }
    }
    
    
    
    func downloadReports() -> Void {
        
        // First we clear all old reports to avoid duplicates
        reports.removeAll()
        
        // Then we get all reports from Firestore
        db.collection("reports").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    let id: String = data["id"] as! String
                    
                    // Check if report is already loaded. If, then don't download it
                    guard self.reports[id] != nil else {
                        print("Skipping loading report with id: \(id)")
                        break
                    }
                    
                    let user: String = data["user"] as! String
                    let photoFilename: String = data["photoFilename"] as! String
                    let timestamp = (data["timestamp"] as! Timestamp).dateValue()
                    let longitude = (data["geolocation"] as! GeoPoint).longitude
                    let latitude = (data["geolocation"] as! GeoPoint).latitude
                    let qrCode: String = data["qrCode"] as! String
                    //let brand: String = data["brand"] as! String
                    let laying: Bool = self.anyIntToBool(data["laying"])
                    let broken: Bool = self.anyIntToBool(data["broken"])
                    let misplaced: Bool = self.anyIntToBool(data["misplaced"])
                    let other: Bool = self.anyIntToBool(data["other"])
                    let comment: String = data["comment"] as! String
                    
                    // Download report photo
                    self.downloadPhoto(filename: photoFilename)                                    
                    
                    let newReport = Report(id: id, user: user, timestamp: timestamp, longitude: longitude, latitude: latitude, qrCode: qrCode, laying: laying, broken: broken, misplaced: misplaced, other: other, comment: comment)
                    
                    print("Adding report with id: \(id)")
                    self.reports[id] = newReport
                    
                    //print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func anyIntToBool (_ input: Any?) -> Bool {
        return 1 != (input! as! Int)
    }
    
}
