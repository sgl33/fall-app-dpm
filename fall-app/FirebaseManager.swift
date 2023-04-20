import SwiftUI
import FirebaseCore
import FirebaseFirestore

/// Connects to Firebase on app launch
///
/// ### Usage
/// ```
/// struct YourApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
///     // stuff...
/// }
/// ```
///
/// ### Author & Version
/// Provided by Firebase, as of Apr. 14, 2023.
///
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

/// Handles all Cloud Firestore-related actions.
///
/// ### Usage
/// All functions are static functions.
/// ```
/// FirestoreHandler.connect() // required
/// FirestoreHandler.addRecord(rec: ...)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 15, 2023
///
class FirestoreHandler {
    static var db: Firestore!
    
    /// Name of collection on Firebase to read records/history from.
    static let records_table: String = "records";
    
    /// Connects to Firestore database. Required before calling other functions.
    static func connect() {
        db = Firestore.firestore()
    }
    
    /// Adds a new walking record to database.
    ///
    /// Must connect to database by calling `FirestoreHandler.connect()` before running.
    ///
    /// ### Example
    /// ```
    /// FirestoreHandler.addRecord(rec: WalkingRecord.toRecord(type: hazards, intensity: intensity))
    /// ```
    static func addRecord(rec: WalkingRecord) {
        var ref: DocumentReference? = nil;
        let docName: String = String(rec.user_id ?? "invalid-id") + "__" + String(rec.timestamp);
        db.collection(records_table).document(docName).setData([
            "user_id": rec.user_id,
            "timestamp": rec.timestamp,
            "hazards": rec.hazards()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Retrieves all records generated by the current device from the database.
    ///
    /// Must connect to database by calling `FirestoreHandler.connect()` before running.
    ///
    /// ### Example
    /// ```
    /// @StateObject var arr = ArrayOfWalkingRecords()
    /// // ...
    /// FirestoreHandler.getRecords(arr: arr)
    /// ```
    static func getRecords(arr: ArrayOfWalkingRecords) {
        
        db.collection(records_table)
            .whereField("user_id", isEqualTo: UIDevice.current.identifierForVendor?.uuidString)
            .order(by: "timestamp")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        let hazards = document.get("hazards") as? [String: Int];
                        let timestamp = document.get("timestamp") as? Double;
                        
                        // Map -> 2 arrays
                        var hazards_type: [String] = [];
                        var hazards_intensity: [Int] = [];
                        for (type, intensity) in hazards ?? [:] {
                            hazards_type.append(type);
                            hazards_intensity.append(intensity);
                        }
                        
                        arr.append(item: WalkingRecord(hazards_type: hazards_type,
                                                       hazards_intensity: hazards_intensity,
                                                       timestamp: timestamp ?? 0));
                    }
                    
                }

            }
    }
}