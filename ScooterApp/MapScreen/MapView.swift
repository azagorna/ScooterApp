// Source: https://www.iosapptemplates.com/blog/swiftui/map-view-swiftui

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupManager()
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
         
        for report in ReportStore.singleton.reportsList {
            
            let location = CLLocationCoordinate2D(latitude: report.latitude!,
                                                  longitude: report.longitude!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = report.getDayAsString() ?? "N/A"
            annotation.subtitle = "Time: \(report.getTimeAsString() ?? "N/A")"
            uiView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if !(annotation is MKPointAnnotation) {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "demo")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "demo")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }

        annotationView!.image = UIImage(named: "image")

        return annotationView

    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
