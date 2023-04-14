import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

struct WalkingRecord {
    var hazards_type: [String];
    var hazards_intensity: [Int];
    let user_id = UIDevice.current.identifierForVendor?.uuidString;
    let timestamp = FieldValue.serverTimestamp();
    
    func hazards() -> [String: Int] {
        var dict: [String: Int] = [:];
        
        hazards_type.indices.forEach { index in
            dict[hazards_type[index]] = hazards_intensity[index];
        }
        
        return dict;
    }
    
    static func toRecord(type: [String], intensity: [Int]) -> WalkingRecord {
        return WalkingRecord(hazards_type: type, hazards_intensity: intensity);
    }
}
