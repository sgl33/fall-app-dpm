//
//  MetaWearManager.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 5/8/23.
//

import MetaWear
import MetaWearCpp

class MetaWearManager
{
    var device: MetaWear!
    
    func scanBoard() {
        print("Scanning...")
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (d) in
            if d.rssi > -60 {
                MetaWearScanner.shared.stopScan()
                d.connectAndSetup().continueWith { t in
                    if let error = t.error {
                        // failed to connect
                        print("ERROR!!")
                        print(error)
                    }
                    else {
                        print("Device connected")
                        Toast.showToast("Device connected!")
                        self.device.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                    }
                }
                self.device = d
                self.device.remember()
            }
        }
    }
    
    func disconnectBoard() {
//        device.cancelConnection().continueWith { t in
//            print("Disconnected")
//            Toast.showToast("Device disconnected")
//        }
    }
    
    func testStart() {
        print("Starting...")
        let board = device.board
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, data) in
            let gyroscope: MblMwCartesianFloat = data!.pointee.valueAs()
            print(data!.pointee.epoch, gyroscope, gyroscope.x, gyroscope.y, gyroscope.z)
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(board)
        print("Started")
    }
    
    func testStop() {
        print("Stopping...")
        let board = device.board
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_gyro_bmi160_stop(self.device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
        mbl_mw_datasignal_unsubscribe(signal)
        print("Stopped")
    }
}

