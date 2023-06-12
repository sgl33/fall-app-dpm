import CoreLocation
import MetaWear
import MetaWearCpp

/// Handles all MetaWear API-related actions.
///
/// ### Usage
/// Most functions are static functions. Functions are static unless otherwise indicated.
/// ```
/// FirestoreHandler.scanBoard() // static
/// FirestoreHandler().startRecording() // non-static
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 15, 2023
///
class MetaWearManager
{
    /// MetaWear device variable
    static var device: MetaWear!
    
    /// RealtimeWalkingData object
    static var realtimeData: RealtimeWalkingData = RealtimeWalkingData()
    
    /// LocationManager object
    static var locationManager = LocationManager()
    
    /// List of document names of realtime (gyroscope and location) data
    static var realtimeDataDocNames: [String] = []
    
    static var recording: Bool = false
    
    /// Scans the board and updates the status on`cso`.
    static func scanBoard(cso: ConnectionStatusObject) {
        print("Scanning...")
        cso.setStatus(status: ConnectionStatus.scanning)
        
        let signalThreshold = -70
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (d) in
            // Close sensor found?
            if d.rssi > signalThreshold {
                MetaWearScanner.shared.stopScan()
                cso.setStatus(status: ConnectionStatus.found)
                
                d.connectAndSetup().continueWith { t in
                    if let error = t.error { // failed to connect
                        print("ERROR!!")
                        print(error)
                        cso.setStatus(status: ConnectionStatus.notConnected)
                    }
                    else { // success
                        print("Device connected")
                        cso.setStatus(status: ConnectionStatus.connected)
                        MetaWearManager.device.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                        WalkingDetectionManager.initialize()
                    }
                    
                    // On disconnected
                    t.result?.continueWith { t in
                        print("Device disconnected, unexpectedly")
                        cso.setStatus(status: ConnectionStatus.notConnected)
                        
                        // notifications
                        if UserDefaults.standard.bool(forKey: "receiveErrorNotifications") {
                            let body = recording ? "Ongoing walking session temporarily suspended. Please reconnect to your IMU sensor on the app." :
                                "Walking detection is not available while disconnected. Please reconnect to your IMU sensor on the app."
                            NotificationManager.sendNotificationNow(title: "Sensor Disconnected",
                                                                    body: body,
                            rateLimit: 60,
                                                                    rateLimitId: "sensorDisconnectAlert")
                        }
                            
                        
                    }
                }
                MetaWearManager.device = d
                MetaWearManager.device.remember()
            }
        }
//        MetaWearManager.locationManager.startRecording()
    }
    
    /// Flashes blue LED on board, to identify boards.
    static func pingBoard() {
        MetaWearManager.device.flashLED(color: .blue, intensity: 1.0, _repeat: 3)
    }
    
    /// Stops scanning for the board and updates the status on `cso`.
    /// Called when user cancels scanning.
    static func stopScan(cso: ConnectionStatusObject) {
        print("Stopping scan")
        MetaWearScanner.shared.stopScan()
        cso.setStatus(status: ConnectionStatus.notConnected)
    }
    
    /// Returns whether a device is connected or not.
    static func connected() -> Bool {
        if device == nil {
            return false;
        }
        return device.isConnectedAndSetup
    }
    
    /// Returns whether a device is connected or not.
    static func connected(_ cso: ConnectionStatusObject) {
        if device == nil {
            cso.conn = false;
        }
        else {
            cso.conn = device.isConnectedAndSetup
        }
    }
    
    /// Disconnects (and resets) the board.
    static func disconnectBoard(cso: ConnectionStatusObject,
                                bso: BatteryStatusObject) {
        device.connectAndSetup().continueWith { t in
            cso.setStatus(status: ConnectionStatus.disconnecting)
            MetaWearManager.device.flashLED(color: .red, intensity: 1.0, _repeat: 1)
            
            device.clearAndReset()
            cso.setStatus(status: ConnectionStatus.notConnected)
            getBattery(bso: bso)
            print("Disconnected")
        }
    }
    
    /// Starts recording the gyroscope and location data.
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    ///
    func startRecording() {
        // Reset
        MetaWearManager.realtimeData.resetData()
        MetaWearManager.locationManager.startRecording()
        MetaWearManager.realtimeDataDocNames = []
        MetaWearManager.recording = true
        
        FirebaseManager.connect()
        
        let board = MetaWearManager.device.board
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_gyro_bmi160_set_odr(board, MBL_MW_GYRO_BOSCH_ODR_50Hz);
        mbl_mw_gyro_bmi160_write_config(board);
        
        // Record
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, data) in
            let gyroscope: MblMwCartesianFloat = data!.pointee.valueAs()
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(gyroscope: gyroscope,
                                                             location: location))
//            print("gyroscope received: \(gyroscope.x)")
            
            // Split it by 2000 data points (40 sec)
            if MetaWearManager.realtimeData.size() > 2000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(gscope: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(MetaWearManager.device.board)
        mbl_mw_gyro_bmi160_start(board)
    }

    /// Sends hazard report to Firebase.
    /// Called when user presses "No, close" or submits a hazard report.
    static func sendHazardReport(hazards: [String], intensity: [Int], imageId: String) {
        // Upload remaining realtime data
        let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
        let documentUuid = UUID().uuidString
        FirebaseManager.addRealtimeData(gscope: copiedObj, docNameUuid: documentUuid)
        MetaWearManager.realtimeDataDocNames.append(documentUuid)
        
        // last location
        let lastLocation = MetaWearManager.realtimeData.data.last?.location ?? [0, 0, 0]
        let lastLocationDict: [String: Double] = ["latitude": lastLocation[0],
                                                  "longitude": lastLocation[1],
                                                  "altitude": lastLocation[2]]
        MetaWearManager.realtimeData.resetData()
        
        // Upload general data
        FirebaseManager.connect()
        FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                   realtimeDataDocNames: MetaWearManager.realtimeDataDocNames,
                                   imageId: imageId,
                                   lastLocation: lastLocationDict)
    }
    
    /// Cancels current walking recording session.
    static func cancelSession() {
        // Upload remaining realtime data
        let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
        let documentUuid = UUID().uuidString
        FirebaseManager.addRealtimeData(gscope: copiedObj, docNameUuid: documentUuid)
        MetaWearManager.realtimeDataDocNames.append(documentUuid)
        MetaWearManager.realtimeData.resetData()
    }
    
    /// Stops recording the gyroscope and location data.
    /// Called when user presses "Stop Recording".
    /// Note that this does not upload any data to the database; `sendHazardReport` must be called separately.
    ///
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    ///
    func stopRecording() {
        let board = MetaWearManager.device.board
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_gyro_bmi160_stop(MetaWearManager.device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(MetaWearManager.device.board)
        mbl_mw_datasignal_unsubscribe(signal)
        MetaWearManager.recording = false
    }
    
    /// Updates `bso` the battery percentage as string, e.g. `75%`.
    static func getBattery(bso: BatteryStatusObject) {
        if(MetaWearManager.connected()) {
            mbl_mw_settings_get_battery_state_data_signal(MetaWearManager.device.board).read().continueWith(.mainThread) {
                    let battery: MblMwBatteryState = $0.result!.valueAs()
                    bso.battery_percentage = String(battery.charge) + "%"

                    let battery_fill: UInt8 = min(battery.charge / 20, 4) * 25
                    bso.battery_icon = "battery." + String(battery_fill)
                }
        }
    }
}



