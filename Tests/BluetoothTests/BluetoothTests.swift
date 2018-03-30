//
//  BluetoothTests.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 11/28/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import XCTest
import Foundation
@testable import Bluetooth

#if os(macOS) || os(iOS) || os(tvOS) || (os(watchOS) && swift(>=3.2))
import CoreBluetooth
#endif

final class BluetoothTests: XCTestCase {
    
    static let allTests = [
        ("testAddress", testAddress),
        ("testUUID", testUUID),
        ("testBitMaskOption", testBitMaskOption),
        ("testUUIDStringParse", testUUIDStringParse)
        ]
    
    func testAddress() {
        
        let addressString = "00:1A:7D:DA:71:13"
        //59:80:ED:81:EE:35
        //AC:BC:32:A6:67:42
        let addressBytes: Address.ByteValue = (0x00, 0x1A, 0x7D, 0xDA, 0x71, 0x13)
        
        guard let address = Address(rawValue: addressString)
            else { XCTFail("Could not parse"); return }
        
        XCTAssert(address.rawValue == addressString, "\(address.rawValue)")
        XCTAssert(address == Address(bigEndian: Address(bytes: addressBytes)))
        XCTAssert(address.hashValue != 0)
    }
    
    func testUUID() {
        
        do {
            
            let uuidString = "2800" // big endian representation
            let uuidValue = GATT.UUID.primaryService.rawValue // 0x2800
            let uuid = BluetoothUUID.bit16(uuidValue)
            
            XCTAssert(uuid.rawValue == uuidString)
            XCTAssert(BluetoothUUID(rawValue: uuidString)?.rawValue == uuidString)
            XCTAssert(uuid.littleEndian.data == Data([0x00, 0x28]))
            XCTAssert(uuid.littleEndian.data != Data([0x28, 0x00]))
            XCTAssert(uuid.littleEndianData == [UInt8](uuid.littleEndian.data))
            XCTAssert(uuid.bigEndian.data == Data([0x28, 0x00]))
        }
        
        do {
            
            /// reversed == C7A8D570-E023-4FB8-E511-72F9E24FF160
            let uuidString = "60F14FE2-F972-11E5-B84F-23E070D5A8C7"
            let uuidValue = UInt128(bigEndian: UInt128(bytes: (0x60, 0xF1, 0x4F, 0xE2, 0xF9, 0x72, 0x11, 0xE5, 0xB8, 0x4F, 0x23, 0xE0, 0x70, 0xD5, 0xA8, 0xC7)))
            
            guard let uuid = BluetoothUUID(rawValue: uuidString)
                else { XCTFail("Could not parse UUID string"); return }
            
            XCTAssert(uuid.rawValue == uuidString)
            XCTAssert(uuid.data == uuidValue.data)
            XCTAssert(uuid.littleEndian.data == Data([0xC7, 0xA8, 0xD5, 0x70, 0xE0, 0x23, 0x4F, 0xB8, 0xE5, 0x11, 0x72, 0xF9, 0xE2, 0x4F, 0xF1, 0x60]))
            XCTAssert(uuid.bigEndian.data == Data([0x60, 0xF1, 0x4F, 0xE2, 0xF9, 0x72, 0x11, 0xE5, 0xB8, 0x4F, 0x23, 0xE0, 0x70, 0xD5, 0xA8, 0xC7]))
            XCTAssert(uuid.bigEndian == .bit128(UInt128(bytes: (0x60, 0xF1, 0x4F, 0xE2, 0xF9, 0x72, 0x11, 0xE5, 0xB8, 0x4F, 0x23, 0xE0, 0x70, 0xD5, 0xA8, 0xC7))))
            XCTAssert(uuid.littleEndian.data == Data([0xC7, 0xA8, 0xD5, 0x70, 0xE0, 0x23, 0x4F, 0xB8, 0xE5, 0x11, 0x72, 0xF9, 0xE2, 0x4F, 0xF1, 0x60]))
            XCTAssert(uuid.bigEndian.data == Data([0x60, 0xF1, 0x4F, 0xE2, 0xF9, 0x72, 0x11, 0xE5, 0xB8, 0x4F, 0x23, 0xE0, 0x70, 0xD5, 0xA8, 0xC7]))
            XCTAssert(BluetoothUUID.init(littleEndian: BluetoothUUID.init(data: Data([0xC7, 0xA8, 0xD5, 0x70, 0xE0, 0x23, 0x4F, 0xB8, 0xE5, 0x11, 0x72, 0xF9, 0xE2, 0x4F, 0xF1, 0x60]))!) == uuid)
            XCTAssert(BluetoothUUID(littleEndianData: [0xC7, 0xA8, 0xD5, 0x70, 0xE0, 0x23, 0x4F, 0xB8, 0xE5, 0x11, 0x72, 0xF9, 0xE2, 0x4F, 0xF1, 0x60]) == uuid)
        }
        
        do {
            
            let uuidString = "FEA9" // BluetoothUUID(rawValue: "FEA9")
            let uuidValue: UInt16 = 0xFEA9 // 65193 Savant Systems LLC
            
            guard let uuid = BluetoothUUID(rawValue: uuidString)
                else { XCTFail("Could not parse UUID string"); return }
            
            XCTAssert(uuid.rawValue == uuidString)
            XCTAssert(uuid.littleEndian.data == Data([uuidValue.littleEndian.bytes.0, uuidValue.littleEndian.bytes.1]))
            XCTAssert(uuid.name == "Savant Systems LLC")
            XCTAssert("\(uuid)" == "FEA9 (Savant Systems LLC)", "\(uuid)")
        }
    }
    
    func testUUIDStringParse() {
        
        let uuids = randomUUIDs
        
        measure { uuids.forEach { _ = BluetoothUUID(rawValue: $0) } }
    }
    
    func testUUIDString() {
        
        let uuids = randomUUIDs.map { BluetoothUUID(rawValue: $0)! }
        
        measure { uuids.forEach { let _ = $0.rawValue } }
    }
    
    func testBitMaskOption() {
        
        do {
            
            // set conversion
            let all = BitMaskOptionSet(ATT.AttributePermission.all)
            
            XCTAssert(all.contains(ATT.AttributePermission.all))
            XCTAssert(all.count == ATT.AttributePermission.all.count)
            XCTAssert(all.count == 8)
            XCTAssert(Set(all) == ATT.AttributePermission.all)
            XCTAssert(all == BitMaskOptionSet<ATT.AttributePermission>.all)
            XCTAssert(all.contains(ATT.AttributePermission.encrypt))
            XCTAssert(all.contains(ATT.AttributePermission.authentication))
            XCTAssert(BitMaskOptionSet<ATT.AttributePermission>().contains(.read) == false)
            XCTAssert(BitMaskOptionSet<ATT.AttributePermission>().contains(ATT.AttributePermission.all) == false)
        }
        
        do {
            
            // Sets are as large as a single element
            XCTAssert(MemoryLayout<BitMaskOptionSet<GATT.CharacteristicProperty>>.size == MemoryLayout<GATT.CharacteristicProperty>.size)
            
            // create empty set
            var set = BitMaskOptionSet<GATT.CharacteristicProperty>()
            XCTAssert(set.count == 0)
            XCTAssert(set.isEmpty)
            XCTAssert(set.rawValue == 0)
            
            // insert value
            set.insert(.read)
            XCTAssert(set.rawValue == GATT.CharacteristicProperty.read.rawValue)
            XCTAssert(set.count == 1)
            XCTAssert(set.isEmpty == false)
            
            // cant store duplicates
            set.insert(.read)
            XCTAssert(set.rawValue == GATT.CharacteristicProperty.read.rawValue)
            XCTAssert(set.count == 1)
            XCTAssert(set.isEmpty == false)
            
            // can store different values
            set.insert(.write)
            XCTAssert(set.rawValue == (GATT.CharacteristicProperty.read.rawValue | GATT.CharacteristicProperty.write.rawValue))
            XCTAssert(set.count == 2)
            XCTAssert(set.isEmpty == false)
            
            // comparison with other collections
            XCTAssert(set.contains([.read, .write]))
            XCTAssert(set == [.read, .write])
        }
        
        do {
            
            var featureSet: LowEnergyFeatureSet = [.encryption, .connectionParametersRequestProcedure, .ping]
            XCTAssert(featureSet.count == 3)
            XCTAssert(featureSet.isEmpty == false)
            XCTAssert(featureSet.contains(.encryption))
            XCTAssert(featureSet.contains(.connectionParametersRequestProcedure))
            XCTAssert(featureSet.contains(.ping))
            XCTAssert(featureSet.contains(.le2mPhy) == false)
            
            XCTAssert(featureSet.rawValue != LowEnergyFeature.encryption.rawValue)
            XCTAssert(featureSet.rawValue != LowEnergyFeature.connectionParametersRequestProcedure.rawValue)
            XCTAssert(featureSet.rawValue != LowEnergyFeature.ping.rawValue)
            XCTAssert(LowEnergyFeature(rawValue: featureSet.rawValue) == nil)
            
            #if swift(>=3.2)
            XCTAssert(LowEnergyFeature.RawValue.bitWidth == LowEnergyFeatureSet.RawValue.bitWidth)
            #endif
            
            XCTAssert(MemoryLayout<LowEnergyFeatureSet>.size == MemoryLayout<LowEnergyFeature.RawValue>.size)
            
            featureSet = .all
            XCTAssert(featureSet.isEmpty == false)
            XCTAssert(featureSet.count == LowEnergyFeature.all.count)
            
            typealias Bit64 = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
            let bigEndianByteValue: Bit64 = (0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01)
            let littleEndianByteValue: Bit64 = (0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
            let rawValue: UInt64 = 0b01
            
            XCTAssert(rawValue.littleEndian.bytes.0 == littleEndianByteValue.0)
            XCTAssert(rawValue.littleEndian.bytes.1 == littleEndianByteValue.1)
            XCTAssert(rawValue.littleEndian.bytes.2 == littleEndianByteValue.2)
            XCTAssert(rawValue.littleEndian.bytes.3 == littleEndianByteValue.3)
            XCTAssert(rawValue.littleEndian.bytes.4 == littleEndianByteValue.4)
            XCTAssert(rawValue.littleEndian.bytes.5 == littleEndianByteValue.5)
            XCTAssert(rawValue.littleEndian.bytes.6 == littleEndianByteValue.6)
            XCTAssert(rawValue.littleEndian.bytes.7 == littleEndianByteValue.7)
            XCTAssert(UInt64(littleEndian: UInt64(bytes: littleEndianByteValue)) == rawValue)
            
            XCTAssert(rawValue.bigEndian.bytes.0 == bigEndianByteValue.0)
            XCTAssert(rawValue.bigEndian.bytes.1 == bigEndianByteValue.1)
            XCTAssert(rawValue.bigEndian.bytes.2 == bigEndianByteValue.2)
            XCTAssert(rawValue.bigEndian.bytes.3 == bigEndianByteValue.3)
            XCTAssert(rawValue.bigEndian.bytes.4 == bigEndianByteValue.4)
            XCTAssert(rawValue.bigEndian.bytes.5 == bigEndianByteValue.5)
            XCTAssert(rawValue.bigEndian.bytes.6 == bigEndianByteValue.6)
            XCTAssert(rawValue.bigEndian.bytes.7 == bigEndianByteValue.7)
            XCTAssert(UInt64(bigEndian: UInt64(bytes: bigEndianByteValue)) == rawValue)
            
            for feature in featureSet {
                
                XCTAssert(LowEnergyFeature.all.contains(feature))
            }
        }
    }
    
    #if os(macOS) || os(iOS) || os(tvOS) || (os(watchOS) && swift(>=3.2))
    
    func testCoreBluetoothUUID() {
        
        do {
            
            let uuid = BluetoothUUID.bit16(0xFEA9)
            
            let coreBluetoothUUID = uuid.toCoreBluetooth()
            
            XCTAssert(coreBluetoothUUID.uuidString == uuid.rawValue)
            
            XCTAssert(uuid.bigEndian.data == coreBluetoothUUID.data, "\(uuid.data) == \(coreBluetoothUUID.data)")
        }
        
        do {
            
            let uuid = BluetoothUUID() // 128 bit
            
            let coreBluetoothUUID = uuid.toCoreBluetooth()
            
            XCTAssert(coreBluetoothUUID.uuidString == uuid.rawValue)
            
            XCTAssert(uuid.bigEndian.data == coreBluetoothUUID.data, "\(uuid.data) == \(coreBluetoothUUID.data)")
        }
        
        do {
            
            let coreBluetoothUUID = CBUUID(string: "FEA9")
            
            let uuid = BluetoothUUID(coreBluetooth: coreBluetoothUUID)
            
            XCTAssert(coreBluetoothUUID.uuidString == uuid.rawValue)
            
            XCTAssert(uuid.bigEndian.data == coreBluetoothUUID.data, "\(uuid.data) == \(coreBluetoothUUID.data)")
        }
        
        do {
            
            let coreBluetoothUUID = CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00067")
            
            let uuid = BluetoothUUID(coreBluetooth: coreBluetoothUUID)
            
            XCTAssert(coreBluetoothUUID.uuidString == uuid.rawValue)
            
            XCTAssert(uuid.bigEndian.data == coreBluetoothUUID.data, "\(uuid.data) == \(coreBluetoothUUID.data)")
        }
    }
    
    func testCoreBluetoothUUIDStringParse() {
        
        let uuids = randomUUIDs
        
        measure { uuids.forEach { _ = CBUUID(string: $0) } }
    }
    
    func testCoreBluetoothUUIDString() {
        
        let uuids = randomUUIDs.map { CBUUID(string: $0) }
        
        measure { uuids.forEach { let _ = $0.uuidString } }
    }
    
    #endif
}

let randomUUIDs = (1 ... 100000).map { _ in UUID().uuidString }
