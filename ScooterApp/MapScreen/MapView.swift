// Source: https://www.iosapptemplates.com/blog/swiftui/map-view-swiftui
// Inspired by: Paul Hudson tutorial, source: https://www.youtube.com/watch?v=fcGiX57a1ww

import MapKit
import SwiftUI
import Foundation

struct MapView: UIViewRepresentable {
    @ObservedObject var reportStore: ReportStore
    @Binding var selectedReport: Report?
    @Binding var showReport: Bool
    
    var locationManager = CLLocationManager()
    
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupManager()
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let reportAnnotations = reportStore.reportsList as [MKAnnotation]
        
        //print("REPORTS:", reportStore.reportsList.debugDescription)
        view.addAnnotations(reportAnnotations)
        //print("DEBUG:", view.annotations)
        
        
        if reportAnnotations.count + 1 != view.annotations.count {
            view.removeAnnotations(view.annotations)
        }
        for report in reportStore.reportsList {
            if report.hasPhoto() {
                //print("Added report pin with photo")
                view.addAnnotation(report as MKAnnotation)
            } else {
                print("Removed pins without photo")
                view.removeAnnotations(view.annotations)
                return
            }
        }
        
//        DispatchQueue.main.async {
//            view.removeAnnotations(reportStore.reportsList as [MKAnnotation])
//            view.addAnnotations(reportStore.reportsList as [MKAnnotation])
//        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, MKMapViewDelegate, ObservableObject {

        @Published var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
                
        func mapView(_ mapView: MKMapView,
                     didSelect view: MKAnnotationView) {
            guard let report = view.annotation as? Report else {
                return
            }
            
            print(report.id, "pin selected")
            parent.selectedReport = report
            parent.showReport = true
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard (view.annotation as? Report) != nil else {
                return
            }
            print(" report pin deselected")
            parent.showReport = false
            parent.selectedReport = nil
        }
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            print("Running mapView")
                        
            if annotation is MKUserLocation {
                return nil
            }
            
            //Annotation must be a report
            guard let report = annotation as? Report  else {
                mapView.removeAnnotation(annotation)
                return nil
            }
            
            //Report must have a photo
            guard let photo = report.photo else {
                mapView.removeAnnotation(annotation)
                return nil
            }
            
            var annotationView: MKAnnotationView? = mapView.view(for: annotation)
            //var annotationView: MKAnnotationView? = MKAnnotationView(annotation: annotation, reuseIdentifier: "X")

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: photo.description)

                print("Report pin rendered for photo: \(report.photo?.description ?? "NONE!")")
                
                //Report must have a photo
                if let photo = report.photo {
                    
                    // Render new round map icon with drop shadows:
                    let size = 60
                    let resizedImage = photo.cropToSquare().resizeImage(newSize: CGSize(width: size*2, height: size*2))
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                    imageView.image = resizedImage
                    imageView.contentMode  = .scaleToFill
                    imageView.layer.cornerRadius = CGFloat(size) / 2
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderWidth = 3.0
                    imageView.layer.borderColor = UIColor.white.cgColor
                    imageView.layer.shouldRasterize = true
                    
                    UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
                    imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let roundBorderImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let roundMarker = UIImageView(frame: CGRect(x: 0, y: 0, width: size+20, height: size+20))
                    roundMarker.image = roundBorderImage
                    roundMarker.contentMode = .center
                    roundMarker.layer.shadowColor = UIColor.black.cgColor
                    roundMarker.layer.shadowOffset = CGSize(width: 0, height: 2.0);
                    roundMarker.layer.shadowRadius = 4.0;
                    roundMarker.layer.shadowOpacity = 0.25;
                    roundMarker.layer.masksToBounds = false
                    roundMarker.clipsToBounds = false;

                    UIGraphicsBeginImageContextWithOptions(roundMarker.frame.size, false, 0.0)
                    roundMarker.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let finalMarkerImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    annotationView?.image =  finalMarkerImage
                    annotationView?.canShowCallout = false
                    //annotationView?.calloutOffset = .init(x: 0, y: 20)
                    //annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                    
                }
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}


//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
