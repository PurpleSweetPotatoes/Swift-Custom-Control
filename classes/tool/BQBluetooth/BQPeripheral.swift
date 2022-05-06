// *******************************************
//  File Name:      BQPeripheral.swift       
//  Author:         MrBai
//  Created Date:   2021/11/16 10:46 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
import CoreBluetooth

public typealias ContentPeripheralsBlock = (_ res: Bool, _ msg: String) -> Void

public enum BQConnectState: Int {
    /// 能进行链接
    case canConnect
    
    /// 已经链接
    case didConenct
    
    /// 已被其他设备链接
    case otherConnect
    
    public var stateName: String {
        switch self {
        case .canConnect:
            return "可连接"
        case .didConenct:
            return "已连接"
        default:
            return "已被其他设备链接"
        }
    }    
}

public class BQPeripheral: NSObject {
    
    public var peripheral: CBPeripheral
    public var advertisementData: [String : Any] = [:]
    public var rssi: NSNumber?
    public var contentBlock: ContentPeripheralsBlock?
    public var connectState: BQConnectState {
        if BQCBCentralManage.contenctArr.contains(self) {
            return .didConenct
        }
        if let state = advertisementData["kCBAdvDataIsConnectable"] as? Int, state == 1 {
            return .otherConnect
        }
        return .canConnect
    }
    
    public init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber?) {
        self.peripheral          = peripheral
        self.advertisementData   = advertisementData
        self.rssi                = rssi
        super.init()
        self.peripheral.delegate = self
    }
    
    public var name: String { return peripheral.name ?? "未知" }
    public var uuidStr: String { return peripheral.identifier.uuidString }
    
    public func configConnectHandle(handle: @escaping ContentPeripheralsBlock) {
        contentBlock = handle
    }
  
    public func callHandle(res: Bool, msg: String) {
        if let block = contentBlock {
            block(res, msg)
        }
    }
}

extension BQPeripheral: CBPeripheralDelegate {

    /// 发现服务
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        BQLogger.debug("扫描后服务列表:\(String(describing: peripheral.services))")
        if let services = peripheral.services {
            for service in services {
                BQLogger.debug("发现服务:\(service.uuid.uuidString)")
            }
        }
    }
    
    /// 发现特征码
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for charact in characteristics {
                BQLogger.debug("发现特征码:\(charact.uuid.uuidString) value:\(String(describing: charact.value))")
            }
        }
    }

    /// 已经写入
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    /// 收到消息
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
