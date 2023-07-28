// *******************************************
//  File Name:      Device+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/11/12 10:31 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Contacts
import Photos
import UIKit

public enum DeviceType {
    case iPhone
    case iPad
    case iPod
    case simulator
    case unknown
}

public extension UIDevice {

    static func getModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            String(cString: ptr)
        }
    }

    static func type() -> DeviceType {
        let modelName = getModelName()

        if modelName.contains("iPhone") {
            return .iPhone
        } else if modelName.contains("iPad") {
            return .iPad
        } else if modelName.contains("iPod") {
            return .iPod
        } else if modelName == "i386" || modelName == "x86_64" {
            return .simulator
        } else {
            return .unknown
        }
    }

    /// IP地址相关(第一个为外网ip)
    static func getIFAddresses() -> [String] {
        var addresses = [String]()

        // Get list of all interfaces on the local machine:
        var ifAddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifAddr) == 0 {
            var ptr = ifAddr
            while ptr != nil {
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee

                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                       nil, socklen_t(0), NI_NUMERICHOST) == 0
                        {
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }

            freeifaddrs(ifAddr)
        }
        return addresses
    }
}

/// Device Auth 
public extension UIDevice {
    enum DeviceAuthModel: Int {
        case camera = 0 // 相机 Privacy - Camera Usage Description
        case photo // 相册 Privacy - Photo Library Usage Description
        case audio // 麦克风 Privacy - Microphone Usage Description
        case contact // 通讯录 Privacy - Contacts Usage Description
    }

    static func authorization(type: DeviceAuthModel, handle: @escaping (_ result: Bool) -> Void) {
        switch type {
        case .camera:
            cameraAuth(handle: handle)
        case .photo:
            photoAuth(handle: handle)
        case .audio:
            audioAuth(handle: handle)
        case .contact:
            contactAuth(handle: handle)
        }
    }

    private static func cameraAuth(handle: @escaping (_ result: Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            handle(true)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { result in
                handle(result)
            }
        } else {
            handle(false)
        }
    }

    private static func photoAuth(handle: @escaping (_ result: Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            handle(true)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                handle(status == .authorized)
            }
        } else {
            handle(false)
        }
    }

    private static func audioAuth(handle: @escaping (_ result: Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized {
            handle(true)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { result in
                handle(result)
            }
        } else {
            handle(false)
        }
    }

    private static func contactAuth(handle: @escaping (_ result: Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized {
            handle(true)
        } else if status == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) { result, _ in
                handle(result)
            }
        } else {
            handle(false)
        }
    }
}
