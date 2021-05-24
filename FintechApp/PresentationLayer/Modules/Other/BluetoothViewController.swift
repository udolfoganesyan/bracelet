//
//  BluetoothViewController.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 23.05.2021.
//  Copyright © 2021 Рудольф О. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController {
    
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    
    @IBOutlet weak var testContainer: UIView!
    @IBOutlet weak var testButton: UIButton!
    
    @IBOutlet weak var callContainer: UIView!
    @IBOutlet weak var callButton: UIButton!
    
    
    //    @IBOutlet weak var heartRateLabel: UILabel!
//    @IBOutlet weak var bodySensorLocationLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Другое"
        
        testContainer.layer.cornerRadius = 12
        testContainer.layer.masksToBounds = true
        testContainer.layer.borderWidth = 2
        testContainer.layer.borderColor = UIColor.black.cgColor
        testButton.layer.cornerRadius = 12
        testButton.layer.masksToBounds = true
        
        callContainer.layer.cornerRadius = 12
        callContainer.layer.masksToBounds = true
        callContainer.layer.borderWidth = 2
        callContainer.layer.borderColor = UIColor.black.cgColor
        callButton.layer.cornerRadius = 12
        callButton.layer.masksToBounds = true
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Make the digits monospaces to avoid shifting when the numbers change
//        heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = ThemeService(themeCore: ThemeCore()).currentTheme.backgroundColor
    }
    
    @IBAction func testButtonAction(_ sender: UIButton) {
        if let url = URL(string: "https://www.mos.ru/city/projects/covid-19/test/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func callButtonAction(_ sender: UIButton) {
        if let url = URL(string: "tel://8-800-2000-112") {
            UIApplication.shared.openURL(url)
        }
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
//        heartRateLabel.text = String(heartRate)
        print("BPM: \(heartRate)")
    }
}

extension BluetoothViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
}

extension BluetoothViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
//            bodySensorLocationLabel.text = bodySensorLocation
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
              let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}
