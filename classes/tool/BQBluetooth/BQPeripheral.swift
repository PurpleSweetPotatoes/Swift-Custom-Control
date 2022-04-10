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

typealias ContentPeripheralsBlock = (_ res: Bool, _ msg: String) -> Void

enum BQConnectState: Int {
    /// 能进行链接
    case canConnect
    
    /// 已经链接
    case didConenct
    
    /// 已被其他设备链接
    case otherConnect
    
    var stateName: String {
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

class BQPeripheral: NSObject {
    
    var peripheral: CBPeripheral
    var advertisementData: [String : Any] = [:]
    var rssi: NSNumber?
    var contentBlock: ContentPeripheralsBlock?
    var connectState: BQConnectState {
        if BQCBCentralManage.contenctArr.contains(self) {
            return .didConenct
        }
        if let state = advertisementData["kCBAdvDataIsConnectable"] as? Int, state == 1 {
            return .otherConnect
        }
        return .canConnect
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber?) {
        self.peripheral          = peripheral
        self.advertisementData   = advertisementData
        self.rssi                = rssi
        super.init()
        self.peripheral.delegate = self
    }
    
    var name: String { return peripheral.name ?? "未知" }
    var uuidStr: String { return peripheral.identifier.uuidString }
    
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
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        BQLogger.log("扫描后服务列表:\(String(describing: peripheral.services))")
        if let services = peripheral.services {
            for service in services {
                BQLogger.log("发现服务:\(service.uuid.uuidString)")
            }
        }
    }
    
    /// 发现特征码
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for charact in characteristics {
                BQLogger.log("发现特征码:\(charact.uuid.uuidString) value:\(String(describing: charact.value))")
            }
        }
    }

    /// 已经写入
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    /// 收到消息
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
