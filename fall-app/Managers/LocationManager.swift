import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let clm = CLLocationManager()
    
    func startRecording() {
        
        
        
        clm.delegate = self
        clm.startUpdatingLocation()
    }
    
    func checkPermissions() {
        // Handle permissions
        let permStatus = CLLocationManager.authorizationStatus()
        if(permStatus == .denied || permStatus == .restricted) {
            print("Location access denied")
            clm.requestAlwaysAuthorization()
        }
        else if(permStatus == .notDetermined) {
            print("Location access not determined")
            clm.requestAlwaysAuthorization()
        }
    }
    
    static func locationDisabled() -> Bool {
        let permStatus = CLLocationManager.authorizationStatus()
        return permStatus != .authorizedAlways && permStatus != .authorizedWhenInUse
    }
    
    func stopRecording() {
        clm.stopUpdatingLocation()
    }
    
    func getLocation() -> [Double] {
        var coord: [Double] = [0, 0, 0]
        
        coord[0] = clm.location?.coordinate.latitude ?? 0
        coord[1] = clm.location?.coordinate.longitude ?? 0
        coord[2] = clm.location?.altitude ?? 0
            
        return coord
    }
}
