import Firebase
import Foundation
import UIKit

class ReportStore: ObservableObject{
    
    static let singleton = ReportStore()
    @Published var reports = [String:Report]()
    @Published var reportsList = [Report]()
    
    //Firebase Stuff
    let DEBUG_DISABLE_SUBMITTING = false
    let DEBUG_DISABLE_DOWNLOADING = false
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let storageRef: StorageReference
    private var lastUpdate = Date()
    private let minTimeIntervalBetweenUpdates: TimeInterval = 5.0 //In seconds
    private var firstLoad = true
    
    // Dispatch
    private let concurrentUploadReportQueue =
        DispatchQueue(label: "uploadReportQueue", qos: .utility)
    private let concurrentUploadReportPhotoQueue =
        DispatchQueue(label: "uploadReportPhotoQueue", qos: .utility)
    
    deinit {
        print("ReportStore was deinitialized!")
    }
    
    private init() {
        //Firebase Stuff
        self.storageRef = storage.reference()
        
        //FOR TESTING ONLY, FAKE REPORTS:
//        self.reports["test1"] = Report(id: "test1", user: "Tester", timestamp: Date(), longitude: 55.0, latitude: 13.0, qrCode: "", laying: true, broken: false, misplaced: true, other: false, comment: "Hello there")
//        self.reports["test1"].photo = UIImage(named: "image_of_lime_scooter")
//        self.reports["test2"] = Report(id: "test2", user: "Tester", timestamp: Date().advanced(by: 100.0), longitude: 56.0, latitude: 12.0, qrCode: "", laying: false, broken: true, misplaced: false, other: true, comment: "Hello again")
//        self.reports["test2"].photo = UIImage(named: "image_of_voi_scooter")
    }
    
    private func sortReportListByDate() {
        self.reportsList.sort(by: {$0.timestamp!.compare($1.timestamp!).rawValue == 1})
    }
    
    private func allowUpdate() -> Bool{
        guard !DEBUG_DISABLE_DOWNLOADING else {
            print("DEBUG_DISABLE_DOWNLOADING is", DEBUG_DISABLE_DOWNLOADING)
            return false
        }
        
        if firstLoad || -lastUpdate.timeIntervalSinceNow >= minTimeIntervalBetweenUpdates  {
            firstLoad = false
            lastUpdate = Date() // If updating was allowed, reset lastUpdate time to now
            return true
        }
        return false
    }
    
    func updateDateFromFirebase() -> Void {
        if (allowUpdate()) {
        print("Getting data from Firebase")
        ReportStore.singleton.downloadReports()
        } else {
            print("Dont fetch too often! Try again in \(String(format: "%.2f", -lastUpdate.timeIntervalSinceNow)) seconds")
        }
    }
        
    func uploadReport (report: Report) {
        guard !DEBUG_DISABLE_SUBMITTING else {
            print("DEBUG_DISABLE_SUBMITTING is", DEBUG_DISABLE_SUBMITTING)
            return
        }
        
        guard report.photo != nil else {
            print("Error in uploadReport()! Report does not have a photo")
            return
        }
        
        // Add report offline:
        self.reports[report.id] = report
        self.reportsList.append(report)
        self.sortReportListByDate()
        
        // Add report to Firebase:
        // Add a new document with a generated ID
        
        concurrentUploadReportQueue.async { [weak self] in
            guard let self = self else {
                  return
            }
                        
            print("Starts uploading report with id: \(report.id)")
            self.db.collection("reports").document(report.id).setData([
                "id": report.id,
                "user": report.user,
                "photoFilename" : report.photoFilename,
                "timestamp": Firebase.Date(timeIntervalSince1970: report.timestamp?.timeIntervalSince1970 ?? Date().timeIntervalSince1970),
                "geolocation": Firebase.GeoPoint(latitude: report.latitude ?? 0.0, longitude: report.longitude ?? 0.0),
                "address": report.getAddressAsString(),
                "qrCode": report.getQRcodeAsString(),
                "brand": report.getBrandAsString(),
                "laying": report.laying,
                "broken": report.broken,
                "misplaced": report.misplaced,
                "other": report.other,
                "comment": report.comment
            ]) { err in
                if let err = err {
                    print("Error uploading document: \(err)")
                } else {
                    print("Report uploaded with id: \(report.id)")
                }
            }
        }
        
        //Upload report photo
        concurrentUploadReportPhotoQueue.async { [weak self] in
            guard let self = self else {
                  return
            }
            
            print("Starts uploading report photo with id: \(report.id)")
            self.uploadPhoto(image: report.photo!, name: report.photoFilename)
            print("Finished uploading report photo with id: \(report.id)")
        }
    }
    
    private func uploadPhoto(image: UIImage, name: String) {
        
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
    
    private func downloadReportPhoto(report: Report) {
    
        // Only download photo if it is not already in the report
        if report.photo == nil {
            
            // Create a reference to the file you want to download
            let photoRef = storageRef.child("/report_images/" + report.photoFilename)
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            
            photoRef.getData(maxSize: 10_000_000) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print()
                    print("Error in ReportStore.downloadPhoto()! No image was returned")
                    print("report_images/" + report.photoFilename)
                    print("Error: \(error)")
                    print()
                    report.photo = nil
                    report.photoDownloadProgress = 0.0
                } else {
                    // Data is returned
                    report.photo = UIImage(data: data!)
                    report.photoDownloadProgress = 1.0
                    print("\(report.photoFilename) added to report")
                }
            }.observe(.progress) { snapshot in
                // observe the download progress by seeting photoDownloadProgress on reports to a value from 0 to 1.0
                report.photoDownloadProgress = Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                print("\(report.photoFilename) downloading: \(Int(report.photoDownloadProgress * 100))%")
              }
        } else {
            report.photoDownloadProgress = 1.0
            print("Skipping \(report.photoFilename), it was already in downloaded photos.")
        }
    }
    
    func downloadReports() -> Void {
        
        // First we clear all old reports to avoid duplicates
        //reports.removeAll()
        
        // Then we get all reports from Firestore
        db.collection("reports").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    // Abort if data does not have an id
                    guard let _ = data["id"] else {
                        print("Download skipped an invalid report without ID")
                        continue
                    }
                    
                    let id: String = data["id"] as! String
                    
                    // Check if report is already loaded. If it is, then don't add it again
                    if ReportStore.singleton.reports[id] == nil  {
                        
                        let user: String = data["user"] as! String
                        //let photoFilename: String = data["photoFilename"] as! String
                        let timestamp = (data["timestamp"] as! Timestamp).dateValue()
                        let longitude = (data["geolocation"] as! GeoPoint).longitude
                        let latitude = (data["geolocation"] as! GeoPoint).latitude
                        let address: String = data["address"] as! String
                        let qrCode: String = data["qrCode"] as! String
                        //let brand: String = data["brand"] as! String
                        let laying: Bool = self.anyIntToBool(data["laying"])
                        let broken: Bool = self.anyIntToBool(data["broken"])
                        let misplaced: Bool = self.anyIntToBool(data["misplaced"])
                        let other: Bool = self.anyIntToBool(data["other"])
                        let comment: String = data["comment"] as! String
                                        
                        let newReport = Report(id: id, user: user, timestamp: timestamp, longitude: longitude, latitude: latitude, address: address, qrCode: qrCode, laying: laying, broken: broken, misplaced: misplaced, other: other, comment: comment)
                        
                        print("Adding report with id: \(id)")
                        ReportStore.singleton.reports[id] = newReport
                        self.reportsList.append(newReport)
                        self.sortReportListByDate()
                        
                        // Download report photo
                        print("Adding photo to report with id: \(id)")
                        self.downloadReportPhoto(report: newReport)
                                                                        
                    } else {
                        //Skip loading already existing and continue to next report
                        print("Skipping already loaded report with id: \(id)")
                    }
                    
                }
            }
        }
    }
    
    func deleteReport(report: Report) {
        
        // Remove from Firebase:
        // Create a reference to the file to delete
        let photoRef = storageRef.child("/report_images/" + report.photoFilename)

        // Delete the report photo from Firebase
        photoRef.delete { error in
          if let error = error {
            print()
            print("Error in ReportStore.deleteReport()!")
            print("report_images/" + report.photoFilename, "was not deleted!")
            print("Error: \(error)")
            print()
          } else {
            // File deleted successfully
            print("report_images/" + report.photoFilename, "was deleted!")
          }
        }
        
        // Delete report document from Firebase
        
        db.collection("reports").document(report.id).delete() { err in
            if let err = err {
                print()
                print("Error removing report: \(err)")
                print("Report \(report.id) was not removed from Firebase!")
                print()
            } else {
                print("Report \(report.id) successfully removed from Firebase!")
            }
        }
        
        // Remove from local storage:
        if let index = reportsList.firstIndex(of: report) {
            reportsList.remove(at: index)
        }
        reports[report.id] = nil
        self.sortReportListByDate()
    }
    
    // Helper function
    private func anyIntToBool (_ input: Any?) -> Bool {
        return 1 == (input! as! Int)
    }
    
}
