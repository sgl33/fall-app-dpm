import SwiftUI
import MapKit
import Polyline

/// MapView that supports polyline drawing.
///
/// ### Usage
/// ```
/// MapView(realtimeData.data.getEncodedPolyline(),
///         hazardEncountered: generalData.hazardEncountered(),
///         hazardLocation: realtimeData.data.getFinalLocation())
/// ```
/// Used in `WalkingRecordView.swift`.
///
/// ### Author & Version
/// Originally by Mauricio Vazquez (https://rb.gy/h983w), retrieved May 15, 2023
/// Using Polyline library: https://github.com/raphaelmor/Polyline/
/// Modified by Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
struct MapView: UIViewRepresentable {
    private let locationViewModel = LocationViewModel()
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 60.0, left: 60.0, bottom: 60.0, right: 60.0)
    let hazardEncountered: [Bool]
    let hazardLocation: [CLLocationCoordinate2D]

    // Single record
    init(_ encodedPolyline: String,
         hazardEncountered: Bool,
         hazardLocation: CLLocationCoordinate2D) {
        self.hazardLocation = [hazardLocation]
        self.hazardEncountered = [hazardEncountered]
        locationViewModel.load(encodedPolyline)
    }
    
    // Multiple records
    init(_ encodedPolyline: [String],
         hazardEncountered: [Bool],
         hazardLocation: [CLLocationCoordinate2D]) {
        self.hazardLocation = hazardLocation
        self.hazardEncountered = hazardEncountered
        
        for p in encodedPolyline {
            locationViewModel.load(p)
        }
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
        
        // Mark hazards (annotations)
        var i: Int = 0
        while i < hazardLocation.count {
            if(hazardEncountered[i]) {
                uiView.addAnnotation(MapAnnotation(hazardLocation[i]))
            }
            i += 1
        }
        
    }

    /// Updates overlays on map.
    /// Called in `updateUIView`.
    private func updateOverlays(from mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        for loc in locationViewModel.locations {
            let polyline = MKPolyline(coordinates: loc, count: loc.count)
            mapView.addOverlay(polyline)
        }
        
        let combinedPolyline = locationViewModel.combineLocations()
        setMapZoomArea(map: mapView, polyline: combinedPolyline,
                       edgeInsets: mapZoomEdgeInsets, animated: true)
    }

    private func setMapZoomArea(map: MKMapView, polyline: MKPolyline,
                                edgeInsets: UIEdgeInsets, animated: Bool = false) {
        map.setVisibleMapRect(polyline.boundingMapRect,
                              edgePadding: edgeInsets,
                              animated: animated)
    }
}

/// Annotations (pins) on map
/// Used in `updateUIView`
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
        renderer.lineWidth = 1.5
        return renderer
    }
}


class LocationViewModel: ObservableObject {
    var locations = [[CLLocationCoordinate2D]]()
  
    func load(_ encodedPolyline: String) {
        fetchLocations(encodedPolyline)
    }
  
    private func fetchLocations(_ encodedPolyline: String) {
        let polyline = Polyline(encodedPolyline: encodedPolyline)
        guard let decodedLocations = polyline.locations else { return }
        locations.append(decodedLocations.map {
            CLLocationCoordinate2D(latitude: $0.coordinate.latitude,
                                   longitude: $0.coordinate.longitude)
        })
    }
    
    func combineLocations() -> MKPolyline {
        var arr: [CLLocationCoordinate2D] = []
        for loc in locations {
            for l in loc {
                arr.append(l)
            }
        }
        return MKPolyline(coordinates: arr, count: arr.count)
    }
}


