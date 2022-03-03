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

typealias DisCoverPeripheralsBlock = (_ peripheral: BQPeripheral) -> Void


class BQCBCentralManage: NSObject {
    
    private let centeral = CBCentralManager(delegate: nil, queue: DispatchQueue.global())
    
    private var discoverBlock: DisCoverPeripheralsBlock?
    private var sevices: [CBUUID]?
    private var options: [String: Any]?
    private var currenConnectPeri: BQPeripheral?
    
    /// 是否正在扫描
    public static var isScan: Bool { get { return sharedManager.centeral.isScanning }}
    
    /// 已连接外设列表
    public static var contenctArr = [BQPeripheral]()
    
    public static func scanPeripherals(sevices:[CBUUID]? = nil, options:[String: Any]? = nil, handle: @escaping DisCoverPeripheralsBlock) {
        
        sharedManager.discoverBlock = handle
        sharedManager.sevices = sevices
        sharedManager.options = options
        
        switch sharedManager.centeral.state {
        case .unknown:
            BQLogger.log("未知")
        case .unsupported:
            BQLogger.log("不支持蓝牙")
        case .poweredOff:
            BQLogger.log("未打开蓝牙")
        case .unauthorized:
            BQLogger.log("未验证")
        case .poweredOn:
            BQLogger.log("蓝牙已打开")
            sharedManager.startScanPerioheral()
        case .resetting:
            BQLogger.log("重置状态")
        default:
            BQLogger.log("其他状态")
        }
    }
    
    public static func stopscan() {
        sharedManager.centeral.stopScan()
        sharedManager.discoverBlock = nil
        sharedManager.sevices = nil
        sharedManager.options = nil
    }

    public static func connect(_ peri: BQPeripheral, options:[String: Any]? = nil) {
        
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
            BQLogger.log("尝试链接\(peri.uuidStr)")
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

    
    public static func deniedAlert() {
        UIAlertController.showAlert(content: "温馨提示", title: "蓝牙授权已被拒绝，请开启蓝牙授权后使用该功能", btnTitleArr: ["取消","前往设置"]) { index in
            if 1 == index {
                BQTool.goPermissionSettings()
            }
        }
    }
}

extension BQCBCentralManage: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        BQLogger.waring("蓝牙状态已改变: \(central.state.rawValue)")
        if let _ = self.discoverBlock, central.state == .poweredOn {
            startScanPerioheral()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let block = self.discoverBlock {
            let per = BQPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            DispatchQueue.main.async {
                block(per)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let per = self.currenConnectPeri, per.uuidStr == peripheral.identifier.uuidString {
            BQCBCentralManage.contenctArr.append(per)
            BQLogger.log("链接设备\(peripheral)-操作设备\(per.peripheral)")
            DispatchQueue.main.async {
                per.callHandle(res: true, msg: "链接成功")
            }
        } else {
            BQLogger.log("链接上设备:\(peripheral.name ?? "null") & \(peripheral.identifier.uuidString)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let per = self.currenConnectPeri, per.uuidStr == peripheral.identifier.uuidString {
            self.currenConnectPeri = nil
            per.callHandle(res: false, msg: error?.localizedDescription ?? "链接设备失败")
        } else {
            BQLogger.error("未能链接设备:\(peripheral.name ?? "null") & \(peripheral.identifier.uuidString)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        BQLogger.log("断开链接\(peripheral)")
    }
}
