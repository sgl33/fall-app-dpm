import CoreLocation
import MetaWear
import MetaWearCpp

/// Handles all MetaWear API-related actions.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
class MetaWearManager
{
    /// MetaWear device variable
    static var device: MetaWear!
    
    static var startLocation: [Double] = []
    static var startTime: Double = 0
    
    /// RealtimeWalkingData object
    static var realtimeData: RealtimeWalkingData = RealtimeWalkingData()
    
    /// LocationManager object
    static var locationManager = LocationManager()
    
    /// List of document names of realtime (gyroscope and location) data
    static var realtimeDataDocNames: [String] = []
    
    /// Whether walking recording or not
    static var recording: Bool = false
    
    
    /// Scans the board and updates the status on`cso`.
    static func scanBoard(cso: ConnectionStatusObject) {
        print("Scanning...")
        cso.setStatus(status: ConnectionStatus.scanning)
        
        let signalThreshold = -73
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
        
        MetaWearManager.startLocation = MetaWearManager.locationManager.getLocation()
        MetaWearManager.startTime = Date().timeIntervalSince1970
        
        // Record
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, data) in
            // Get and add data
            let gyroscope: MblMwCartesianFloat = data!.pointee.valueAs()
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(gyroscope: gyroscope,
                                                             location: location))
            
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
    static func sendHazardReport(hazards: [String],
                                 intensity: [Int],
                                 imageId: String,
                                 buildingId: String = "",
                                 buildingFloor: String = "",
                                 buildingRemarks: String = "",
                                 buildingHazardLocation: String = "") {
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
        let startLocationDict: [String: Double] = ["latitude": startLocation[0],
                                                  "longitude": startLocation[1],
                                                  "altitude": startLocation[2]]
        MetaWearManager.realtimeData.resetData()
        
        // Upload general data
        FirebaseManager.connect()
        FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                  realtimeDataDocNames: MetaWearManager.realtimeDataDocNames,
                                  imageId: imageId,
                                  lastLocation: lastLocationDict,
                                  startLocation: startLocationDict,
                                  startTime: startTime,
                                  buildingId: buildingId,
                                  buildingFloor: buildingFloor,
                                  buildingRemarks: buildingRemarks,
                                  buildingHazardLocation: buildingHazardLocation)
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
    
    /// Stops recording the gyroscope and location data. Called when user presses "Stop Recording".
    ///
    /// Note: This does not upload any data to the database; `sendHazardReport` must be called separately.
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
    
    /// Gets battery data from sensor and updates `bso`
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



