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
/// Modified by Seung-Gu Lee, last modified Jun. 1, 2023
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
    /// FirestoreHandler.addRecord(rec: WalkingRecord.toRecord(type: hazards, intensity: intensity),
    ///                             gscope: &MetaWearManager.walkingData)
    /// ```
    static func addRecord(rec: GeneralWalkingData,
                          realtimeDataDocNames: [String]) { // passed by reference
        var ref: DocumentReference? = nil;
        let docName: String = String(rec.user_id ?? "invalid-id") + "___" + String(rec.timestampToDateInt());
        db.collection(records_table).document(docName).setData([
            "user_id": rec.user_id,
            "timestamp": rec.timestamp,
            "hazards": rec.hazards(),
            "gscope_data": realtimeDataDocNames
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Edits an existing hazard report.
    /// `rec` must have a valid `docName` field
    static func editHazardReport(rec: GeneralWalkingData) {
        var ref: DocumentReference? = nil;
        db.collection(records_table).document(rec.docName).setData([
            "user_id": rec.user_id,
            "timestamp": rec.timestamp,
            "hazards": rec.hazards(),
            "gscope_data": rec.realtimeDocNames
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(rec.docName) successfully written!")
            }
        }
    }
    
    /// Adds gyroscope and location data to Firebase on specified document name.
    ///
    /// Must connect to database by calling `FirestoreHandler.connect()` before running.
    ///
    static func addRealtimeData(gscope: RealtimeWalkingData,
                                docNameUuid: String) {
        var ref: DocumentReference? = nil;
        let docName: String = docNameUuid;
        db.collection("realtime_data").document(docName).setData([
            "gscope_data": gscope.toArrDict()
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
    static func getRecords(arr: WalkingRecordsArr) {
        arr.startFetching()
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
                        let realtimeDocNames = document.get("gscope_data") as? [String]
                        
                        // Map -> 2 arrays
                        var hazards_type: [String] = [];
                        var hazards_intensity: [Int] = [];
                        for (type, intensity) in hazards ?? [:] {
                            hazards_type.append(type);
                            hazards_intensity.append(intensity);
                        }
                        
                        arr.append(item: GeneralWalkingData(docName: document.documentID,
                            hazards_type: hazards_type,
                                                            hazards_intensity: hazards_intensity,
                                                            timestamp: timestamp ?? 0,
                                                            realtimeDocNames: realtimeDocNames ?? ["not_found"]));
                    }
                    arr.doneFetching()
                }
            }
    }
    
    /// Retrieve realtime gyroscope and location data from the database using `docNames`
    /// and saves them into a single object (`loader`).
    static func loadRealtimeData(loader: RealtimeWalkingDataLoader,
                                 docNames: [String]) {
        loader.clear()
        loader.isLoading = true
        
        var index: Int = 0
        var count: Int = 0
        
        // For each document name
        for docName in docNames {
            let docIndex = index
            let docRef = db.collection("realtime_data") .document(docName)
            docRef.getDocument { (document, err) in
                if let document = document, document.exists {
                    let realtimeData = document.get("gscope_data") as? [[String: Double]]
                    loader.tempData[docIndex] = RealtimeWalkingData(arr: realtimeData ?? [[:]])
                    count += 1
                    
                    // Done - loaded all data
                    if count == docNames.count {
                        loader.combineTempData(numDocs: docNames.count)
                        loader.isLoading = false
                    }
                } else {
                    print("Document \(docName) does not exist")
                }
            }
            
            index += 1
        }
    }
    
    /// Retrieve realtime gyroscope and location data from the database using `docNames`
    /// and saves them into a single object (`loader`).
    ///
    /// This version of the function keeps track of number of records loaded on `multiLoader`.
    ///
    ///
    static func loadRealtimeData(loader: RealtimeWalkingDataLoader,
                                 docNames: [String],
                                 multiLoader: MultiWalkingLoader) {
        loader.clear()
        loader.isLoading = true
        
        var index: Int = 0
        var count: Int = 0
        
        // For each document name
        for docName in docNames {
            let docIndex = index
            let docRef = db.collection("realtime_data") .document(docName)
            docRef.getDocument { (document, err) in
                if let document = document, document.exists {
                    let realtimeData = document.get("gscope_data") as? [[String: Double]]
                    loader.tempData[docIndex] = RealtimeWalkingData(arr: realtimeData ?? [[:]])
                    count += 1
                    multiLoader.onSingleRealtimeDataLoaded() // the only difference!
                    
                    // Done - loaded all data
                    if count == docNames.count {
                        loader.combineTempData(numDocs: docNames.count)
                        loader.isLoading = false
                    }
                } else {
                    print("Document \(docName) does not exist")
                }
            }
            
            index += 1
        }
    }
    
    /// Retrieves all records of all users.
    /// Used by "View records from all trips", not to be used in production
    static func getAllRecords(loader: MultiWalkingLoader) {
//        loader.reset()
        loader.start()
        // All records
        db.collection(records_table)
            .order(by: "timestamp")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        let hazards = document.get("hazards") as? [String: Int];
                        let timestamp = document.get("timestamp") as? Double;
                        let realtimeDocNames = document.get("gscope_data") as? [String]
                        
                        // Map -> 2 arrays
                        var hazards_type: [String] = [];
                        var hazards_intensity: [Int] = [];
                        for (type, intensity) in hazards ?? [:] {
                            hazards_type.append(type);
                            hazards_intensity.append(intensity);
                        }
                        
                        let generalData = GeneralWalkingData(docName: document.documentID,
                                                             hazards_type: hazards_type,
                                                             hazards_intensity: hazards_intensity,
                                                             timestamp: timestamp ?? 0,
                                                             realtimeDocNames: realtimeDocNames ?? ["not_found"]);
                        let realtimeLoader = RealtimeWalkingDataLoader()
                        loader.addRecord(generalData, realtimeLoader)
                        FirestoreHandler.loadRealtimeData(loader: realtimeLoader, docNames: realtimeDocNames ?? ["not_found"])
                    }
                }
            }
    }
}
