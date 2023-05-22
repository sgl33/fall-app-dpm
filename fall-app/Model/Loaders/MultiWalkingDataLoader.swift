import Foundation
import MapKit

/// Object used to load multiple walking sessions at once.
///
/// ### Usage
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
class MultiWalkingLoader: ObservableObject {
    
    var realtimeLoader: [(GeneralWalkingData, RealtimeWalkingDataLoader)] = []
    
    /// Update this to refresh the screen
    @Published var isLoading: Bool = false
    var realtimeDataLoaded: Int = 0
    
    func start() {
        isLoading = true
    }
    
    func addRecord(_ g: GeneralWalkingData, _ r: RealtimeWalkingDataLoader) {
        realtimeLoader.append((g, r))
    }
    
    /// Called when a realtime data of a single record is done loading.
    func onSingleRealtimeDataLoaded() {
        realtimeDataLoaded += 1
        // done loading
        if(realtimeDataLoaded == realtimeLoader.count) {
            isLoading = false
        }
    }
    
    func reset() {
        realtimeDataLoaded = 0
        isLoading = false
        realtimeLoader = []
    }
    
    func getEncodedPolylines() -> [String] {
        var arr: [String] = []
        var i: Int = 0
        while i < realtimeLoader.count {
            let polyline = realtimeLoader[i].1.data.getEncodedPolyline()
            arr.append(polyline)
            i += 1
        }
        return arr
    }
    
    func hazardEncountered() -> [Bool] {
        var arr: [Bool] = []
        var i: Int = 0
        while i < realtimeLoader.count {
            let polyline = realtimeLoader[i].0.hazardEncountered()
            arr.append(polyline)
            i += 1
        }
        return arr
    }
    
    func getFinalLocation() -> [CLLocationCoordinate2D] {
        var arr: [CLLocationCoordinate2D] = []
        var i: Int = 0
        while i < realtimeLoader.count {
            let polyline = realtimeLoader[i].1.data.getFinalLocation()
            arr.append(polyline)
            i += 1
        }
        return arr
    }
}
