import SwiftUI
import MapKit
import Polyline

///
///
/// ### Author & Version
/// Originally by Mauricio Vazquez (https://rb.gy/h983w), retrieved May 15, 2023
/// https://github.com/raphaelmor/Polyline/
/// Modified by Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct MapView: UIViewRepresentable {
    private let locationViewModel = LocationViewModel()
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 60.0, left: 60.0, bottom: 60.0, right: 60.0)
    let hazardEncountered: Bool
    let hazardLocation: CLLocationCoordinate2D

    init(_ encodedPolyline: String, hazardEncountered: Bool, hazardLocation: CLLocationCoordinate2D) {
        self.hazardLocation = hazardLocation
        self.hazardEncountered = hazardEncountered
        locationViewModel.load(encodedPolyline)
    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = false
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        updateOverlays(from: uiView)
        
        if(hazardEncountered) {
            uiView.addAnnotation(MapAnnotation(hazardLocation))
        }
    }

    private func updateOverlays(from mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        let polyline = MKPolyline(coordinates: locationViewModel.locations, count: locationViewModel.locations.count)
        mapView.addOverlay(polyline)
        setMapZoomArea(map: mapView, polyline: polyline, edgeInsets: mapZoomEdgeInsets, animated: true)
        
        
    }

    private func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
}

class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.title = ""
        self.subtitle = ""
        self.coordinate = coordinate
    }
}


final class MapViewCoordinator: NSObject, MKMapViewDelegate {
    private let map: MapView

    init(_ control: MapView) {
        self.map = control
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotationView = views.first, let annotation = annotationView.annotation {
            
            if annotation is MKUserLocation {
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
        
        
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 3.0
        return renderer
    }
}


class LocationViewModel: ObservableObject {
    var locations = [CLLocationCoordinate2D]()
  
    func load(_ encodedPolyline: String) {
        fetchLocations(encodedPolyline)
    }
  
    private func fetchLocations(_ encodedPolyline: String) {
        let polyline = Polyline(encodedPolyline: encodedPolyline)
        guard let decodedLocations = polyline.locations else { return }
        locations = decodedLocations.map { CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)}
    }
}


