//
//  CGMSessionRunTime.swift
//  Bluetooth
//
//  Created by Carlos Duclos on 6/20/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/**
 CGM Session Run Time
 
 [CGM Session Run Time](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cgm_session_run_time.xml)
 
 - Note:
 C1: Mandatory if device supports E2E-CRC (Bit 12 is set in CGM Feature) otherwise excluded.
 
 The fields in the above table are in the order of LSO to MSO. Where LSO = Least Significant Octet and MSO = Most Significant Octet
 */
public struct CGMSessionRunTime: GATTCharacteristic {
    
    public static var uuid: BluetoothUUID { return .cgmSessionRunTime }
    
    internal static let length = MemoryLayout<UInt16>.size
    
    internal static let minLength = 2
    
    internal static let maxLength = 4
    
    public var sessionRunTime: UInt16
    
    public var e2ecrc: GATTE2ecrc?
    
    public init(sessionRunTime: UInt16, e2ecrc: GATTE2ecrc? = nil) {
        
        self.sessionRunTime = sessionRunTime
        self.e2ecrc = e2ecrc
    }
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).minLength
            else { return nil }
        
        let sessionRunTime = UInt16(littleEndian: UInt16(bytes: (data[0], data[1])))
        
        let validLength = (data.count == type(of: self).maxLength)
        let e2ecrc: GATTE2ecrc? = validLength ? GATTE2ecrc(rawValue: UInt16(littleEndian: UInt16(bytes: (data[2], data[3])))) : nil
        
        self.init(sessionRunTime: sessionRunTime, e2ecrc: e2ecrc)
    }
    
    public var data: Data {
        
        let sessionRunTimeBytes = sessionRunTime.littleEndian.bytes
        
        let totalBytes = e2ecrc != nil ? type(of: self).maxLength : type(of: self).minLength
        
        var data = Data()
        data.reserveCapacity(totalBytes)
        
        data += [sessionRunTimeBytes.0, sessionRunTimeBytes.1]
        
        if let e2ecrcBytes = e2ecrc?.rawValue.littleEndian.bytes {
            
            data += [e2ecrcBytes.0, e2ecrcBytes.1]
        }
        
        return data
    }
}

extension CGMSessionRunTime: Equatable {
    
    public static func == (lhs: CGMSessionRunTime, rhs: CGMSessionRunTime) -> Bool {
        
        return lhs.sessionRunTime == rhs.sessionRunTime && lhs.e2ecrc == rhs.e2ecrc
        
    }
}

extension CGMSessionRunTime: CustomStringConvertible {
    
    public var description: String {
        
        return "\(sessionRunTime) \(e2ecrc?.description ?? "")"
    }
}
