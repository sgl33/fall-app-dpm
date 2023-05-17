import Foundation

/// A class that contains an array of general and realtime data objects.
///
/// Create a `@StateObject` of this type, and pass it by reference to the `FirestoreHandler`.
///
class WalkingRecordsArr: ObservableObject {
    
    @Published var generalDataArr: [GeneralWalkingData] = [];
    
    @Published var realtimeDataArr: [RealtimeWalkingData] = [];
    
    @Published var done: Bool = false;
    
    /// Add item to `generalDataArr`.
    func append(item: GeneralWalkingData) {
        generalDataArr.append(item);
    }
    
    /// Add item to `realtimeDataArr`.
    func append(item: RealtimeWalkingData) {
        realtimeDataArr.append(item);
    }
    
    /// Return `generalDataArr`
    func getGeneralDataArr() -> [GeneralWalkingData] {
        return generalDataArr;
    }
    
    /// Return `realtimeDataArr`
    func getRealtimeDataArr() -> [RealtimeWalkingData] {
        return realtimeDataArr;
    }
    
    /// Clear both arrays
    func clearArr() {
        generalDataArr = [];
        realtimeDataArr = [];
    }
    
    /// Call this when starting to fetch data from database.
    /// Used to display loading skeleton UI.
    func startFetching() {
        done = false;
        print("Started fetching data from database")
    }
    
    /// Call this when data fetching is complete.
    /// Used to stop displaying skeleton UI.
    func doneFetching() {
        done = true;
        print("Done fetching data from database")
    }
    
    /// Return `done`, i.e. whether database access has been complete
    func isDoneFetching() -> Bool {
        return done;
    }
}
