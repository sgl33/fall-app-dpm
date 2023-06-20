import Foundation
import CoreLocation

/// Class that stores building information
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 19, 2023
///
class BuildingsLoader: ObservableObject {
    var buildings: [Building] = []
    @Published var loading: Bool = false
    
    func append(id: String, name: String, address: String,
                latitude: Double, longitude: Double, floorPlans: [String: String]) {
        buildings.append(Building(id: id, name: name, address: address, latitude: latitude,
                                  longitude: longitude, floorPlans: floorPlans))
    }
    
    func getBuildingMarkers() -> [SurveyBuildingsView.BuildingMarker] {
        var val: [SurveyBuildingsView.BuildingMarker] = []
        for building in buildings {
            val.append(.init(name: building.name,
                             coordinate: CLLocationCoordinate2D(latitude: building.latitude,
                                                                longitude: building.longitude)))
        }
        return val
    }
    
    func sortByDistance(from: CLLocationCoordinate2D) {
        buildings.sort {
            $0.getDistanceFeet(from: from) < $1.getDistanceFeet(from: from)
        }
    }
    
    func clear() {
        buildings = []
        loading = false
    }
}

struct Building: Identifiable {
    var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var floorPlans: [String: String] // floor name, floor plan image filename
    
    func getDistanceFeet(from: CLLocationCoordinate2D) -> Int {
        let to = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let feet = Int(from.distance(to: to).magnitude / 0.3048)
        return feet
    }
    
    func getDistanceString(from: CLLocationCoordinate2D) -> String {
        return "\(getDistanceFeet(from: from)) ft"
    }
}
