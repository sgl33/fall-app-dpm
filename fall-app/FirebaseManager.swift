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
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 14, 2023
///
class FirestoreHandler {
    static var db: Firestore!
    
    /// Connects to Firestore database. Required before calling other functions.
    static func connect() {
        db = Firestore.firestore()
    }
    
    /// Adds a new walking record to database.
    ///
    /// ### Example
    /// ```
    /// FirestoreHandler.addRecord(rec: WalkingRecord.toRecord(type: hazards, intensity: intensity))
    /// ```
    static func addRecord(rec: WalkingRecord) {
        var ref: DocumentReference? = nil;
        ref = db.collection("records").addDocument(data: [
            "user_id": rec.user_id,
            "timestamp": rec.timestamp,
            "hazards": rec.hazards()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
}
