/// struct WalkingRecord
/// class ArrayOfWalkingRecords: ObservableObject
/// 

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

/// A struct that stores data about a record.
struct WalkingRecord {
    
    /// Array of hazard types.
    var hazards_type: [String];
    
    /// Intensity of each hazard type. Size must match that of `hazards_type`.
    var hazards_intensity: [Int];
    
    /// Device identifier, automatically generated.
    let user_id = UIDevice.current.identifierForVendor?.uuidString;
    
    /// Current timestamp in seconds from Jan. 1, 1970
    var timestamp = NSDate().timeIntervalSince1970;
    
    /// Retrieves the list of hazards as a form of dictionary (key = String, value = Int).
    func hazards() -> [String: Int] {
        var dict: [String: Int] = [:];
        
        hazards_type.indices.forEach { index in
            dict[hazards_type[index]] = hazards_intensity[index];
        }
        
        return dict;
    }
    
    /// Retrieves the timestamp as a user-friendly string.
    ///
    /// ### Format
    /// `h:mm a, MMM. d, yyyy`
    /// Example: `11:34 AM, Jan. 15, 2023`
    ///
    func timestampToString() -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a, MMM. d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    /// Retrieves the reported hazards in array of strings.
    ///
    /// ### Example
    /// ```
    /// ["Slippery (low)", "Poor Lighting (high)"]
    /// ```
    /// If no hazard was reported by user,
    /// ```
    /// ["No hazard reported."]
    /// ```
    ///
    func hazardsToStringArr() -> [String] {
        var strArr: [String] = [];
        var index: Int = 0;
        var count: Int = 0;
        let optionTexts: [String] = ["none", "low", "medium", "high"]
        
        for intensity in hazards_intensity {
            if(intensity > 0) {
                count += 1;
                strArr.append(hazards_type[index] + " ("
                              + optionTexts[intensity] + ")")
            }
            index += 1;
        }
        
        if(count <= 0) {
            return ["No hazard reported."]
        }
        else {
            return strArr;
        }
    }
    
    /// Creates and returns a WalkingRecord object given two arrays.
    static func toRecord(type: [String], intensity: [Int]) -> WalkingRecord {
        return WalkingRecord(hazards_type: type, hazards_intensity: intensity);
    }
}

/// A class that contains an array of `WalkingRecord` objects.
///
/// Create a `@StateObject` of this type, and pass it by reference to the `FirestoreHandler`.
///
class ArrayOfWalkingRecords: ObservableObject {
    @Published var arr: [WalkingRecord] = [];
    @Published var done: Bool = false;
    
    /// Add item to `arr`.
    func append(item: WalkingRecord) {
        arr.append(item);
    }
    
    /// Return `arr`
    func getArr() -> [WalkingRecord] {
        return arr;
    }
    
    /// Clear `arr`
    func clearArr() {
        arr = [];
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
