import Foundation
import CoreLocation
import MetaWear
import MetaWearCpp

/// A struct that stores GPS location, gyroscope data, and timestamp.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct GyroscopeData {
    
    /// Gyroscope data
    var gyroscope: MblMwCartesianFloat
    
    /// GPS Location of the data: (latitude, longitude, altitude)
    var location: [Double]
    
    /// Current timestamp in seconds from Jan. 1, 1970
    var timestamp = NSDate().timeIntervalSince1970;
}

class GyroscopeDataArr {
    
    var data: [GyroscopeData] = []
    
    func addData(_ data: GyroscopeData) {
        self.data.append(data)
    }
    
    func resetData() {
        self.data = []
    }
    
    /// Returns data in array of dictionaries, readable by Firebase
    func toArrDict() -> [[String: Double]] {
        var arr: [[String: Double]] = []
        
        for d in data {
            let dict: [String: Double] = [
                "timestamp": d.timestamp,
                "location_latitude": d.location[0],
                "location_longitude": d.location[1],
                "location_altitude": d.location[2],
                "gyroscope_x": Double(d.gyroscope.x),
                "gyroscope_y": Double(d.gyroscope.y),
                "gyroscope_z": Double(d.gyroscope.z)
            ]
            arr.append(dict)
        }
        
        return arr
    }
}
