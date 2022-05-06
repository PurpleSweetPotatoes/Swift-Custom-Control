// *******************************************
//  File Name:      BQCBCentralManage.swift       
//  Author:         MrBai
//  Created Date:   2021/11/15 5:31 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

import CoreBluetooth

let sharedManager = BQCBCentralManage()
public typealias DisCoverPeripheralsBlock = (_ peripheral: BQPeripheral) -> Void


public class BQCBCentralManage: NSObject {
    
    private let centeral = CBCentralManager(delegate: nil, queue: DispatchQueue.global())
    
    private var discoverBlock: DisCoverPeripheralsBlock?
    private var sevices: [CBUUID]?
    private var options: [String: Any]?
    private var currenConnectPeri: BQPeripheral?
    
    /// 是否正在扫描
    static var isScan: Bool { return sharedManager.centeral.isScanning }
    
    /// 已连接外设列表
    static var contenctArr = [BQPeripheral]()
    
    class public func scanPeripherals(sevices:[CBUUID]? = nil, options:[String: Any]? = nil, handle: @escaping DisCoverPeripheralsBlock) {
        
        sharedManager.discoverBlock = handle
        sharedManager.sevices = sevices
        sharedManager.options = options
        
        switch sharedManager.centeral.state {
        case .unknown:
            BQLogger.debug("未知")
        case .unsupported:
            BQLogger.debug("不支持蓝牙")
        case .poweredOff:
            BQLogger.debug("未打开蓝牙")
        case .unauthorized:
            BQLogger.debug("未验证")
        case .poweredOn:
            BQLogger.debug("蓝牙已打开")
            sharedManager.startScanPerioheral()
        case .resetting:
            BQLogger.debug("重置状态")
        default:
            BQLogger.debug("其他状态")
        }
    }
    
    class public func stopscan() {
        sharedManager.centeral.stopScan()
        sharedManager.discoverBlock = nil
        sharedManager.sevices = nil
        sharedManager.options = nil
    }

    class public func connect(_ peri: BQPeripheral, options:[String: Any]? = nil) {
        
        if let _ = sharedManager.currenConnectPeri {
            if sharedManager.currenConnectPeri == peri {
                sharedManager.centeral.cancelPeripheralConnection(peri.peripheral)
            } else {
                peri.callHandle(res: false, msg: "当前有设备正在连接中，请稍后再试")
            }
            return
        }
        
        if peri.contentBlock == nil {
            BQHudView.show("请先配置链接回调函数")
            return
        }
        
        switch peri.connectState {
        case .canConnect:
            BQLogger.debug("尝试链接\(peri.uuidStr)")
            sharedManager.currenConnectPeri = peri
            sharedManager.centeral.connect(peri.peripheral, options: options)
        case .didConenct:
            
            peri.callHandle(res: true, msg: "已连接")
        case .otherConnect:
            peri.callHandle(res: false, msg: "已被其他设备链接，无法链接")
        }
    }
    
    override init() {
        super.init()
        centeral.delegate = self
    }
    
    private func startScanPerioheral() {
        centeral.scanForPeripherals(withServices: sevices, options: options)
    }

    
    class public func deniedAlert() {
        UIAlertController.showAlert(content: "温馨提示", title: "蓝牙授权已被拒绝，请开启蓝牙授权后使用该功能", btnTitleArr: ["取消","前往设置"]) { index in
            if 1 == index {
                BQTool.goPermissionSettings()
            }
        }
    }
}

extension BQCBCentralManage: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        BQLogger.debug("蓝牙状态已改变: \(central.state.rawValue)")
        if let _ = self.discoverBlock, central.state == .poweredOn {
            startScanPerioheral()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let block = self.discoverBlock {
            let per = BQPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            DispatchQueue.main.async {
                block(per)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let per = self.currenConnectPeri, per.uuidStr == peripheral.identifier.uuidString {
            BQCBCentralManage.contenctArr.append(per)
            BQLogger.debug("链接设备\(peripheral)-操作设备\(per.peripheral)")
            DispatchQueue.main.async {
                per.callHandle(res: true, msg: "链接成功")
            }
        } else {
            BQLogger.debug("链接上设备:\(peripheral.name ?? "null") & \(peripheral.identifier.uuidString)")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let per = self.currenConnectPeri, per.uuidStr == peripheral.identifier.uuidString {
            self.currenConnectPeri = nil
            per.callHandle(res: false, msg: error?.localizedDescription ?? "链接设备失败")
        } else {
            BQLogger.error("未能链接设备:\(peripheral.name ?? "null") & \(peripheral.identifier.uuidString)")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        BQLogger.debug("断开链接\(peripheral)")
    }
}
