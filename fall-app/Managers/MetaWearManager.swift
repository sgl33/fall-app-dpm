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
    
    /// Scans the board and updates the status on`cso`.
    static func scanBoard(cso: ConnectionStatusObject) {
        print("Scanning...")
        cso.setStatus(status: ConnectionStatus.scanning)
        
        let signalThreshold = -65
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (d) in
            // Close sensor found?
            if d.rssi > signalThreshold {
                MetaWearScanner.shared.stopScan()
                cso.setStatus(status: ConnectionStatus.found)
                
                d.connectAndSetup().continueWith { t in
                    if let error = t.error {
                        // failed to connect
                        print("ERROR!!")
                        print(error)
                        cso.setStatus(status: ConnectionStatus.notConnected)
                    }
                    else {
                        // success
                        print("Device connected")
                        cso.setStatus(status: ConnectionStatus.connected)
                        MetaWearManager.device.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                    }
                    
                    // Disconnected
                    t.result?.continueWith { t in
                        cso.setStatus(status: ConnectionStatus.notConnected)
                    }
                }
                MetaWearManager.device = d
                MetaWearManager.device.remember()
            }
        }
    }
    
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
    ///
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    ///
    func startRecording() {
        // Reset
        MetaWearManager.realtimeData.resetData()
        MetaWearManager.locationManager.startRecording()
        MetaWearManager.realtimeDataDocNames = []
        
        FirestoreHandler.connect()
        
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
            print("gyroscope received: \(gyroscope.x)")
            
            // Split it by 2000 data points (40 sec)
            if MetaWearManager.realtimeData.size() > 2000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirestoreHandler.addRealtimeData(gscope: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(MetaWearManager.device.board)
        mbl_mw_gyro_bmi160_start(board)
    }

    static func sendHazardReport(hazards: [String], intensity: [Int]) {
        // Upload remaining realtime data
        let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
        let documentUuid = UUID().uuidString
        FirestoreHandler.addRealtimeData(gscope: copiedObj, docNameUuid: documentUuid)
        MetaWearManager.realtimeDataDocNames.append(documentUuid)
        MetaWearManager.realtimeData.resetData()
        
        // Upload
        FirestoreHandler.connect()
        FirestoreHandler.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                   realtimeDataDocNames: MetaWearManager.realtimeDataDocNames)
    }
    
    /// Stops recording the gyroscope and location data.
    ///
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    ///
    func stopRecording() {
        let board = MetaWearManager.device.board
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_gyro_bmi160_stop(MetaWearManager.device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(MetaWearManager.device.board)
        mbl_mw_datasignal_unsubscribe(signal)
        MetaWearManager.locationManager.stopRecording()
    }
    
    /// Updates `bso` the battery percentage as string, e.g. `75%`.
    /// If device is disconnected or cannot retrieve the percentage for some reason, returns "Unknown"
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

/// Status of the connection between the sensor and the iPhone.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 9, 2023
///
class ConnectionStatusObject: ObservableObject {
    
    @Published var status: ConnectionStatus = ConnectionStatus.notConnected;
    @Published var conn: Bool = false

    func setStatus(status: ConnectionStatus) {
        self.status = status
    }
    
    func getStatus() -> ConnectionStatus {
        return self.status
    }
    
    func showModal() -> Bool {
        return self.status == ConnectionStatus.scanning ||
            self.status == ConnectionStatus.found
    }
    
    func connected() -> Bool {
        return self.status == ConnectionStatus.connected
    }
}

/// Enum indicating connection status between the sensor and the iPhone.
enum ConnectionStatus {
    case notConnected, scanning, found, disconnecting, connected
}

/// Call `.refresh()` to refresh the screen for async methods. Once per object only.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 9, 2023
///
class BatteryStatusObject: ObservableObject {
    @Published var battery_percentage: String = "-"
    @Published var battery_icon: String = "battery.0"
}
