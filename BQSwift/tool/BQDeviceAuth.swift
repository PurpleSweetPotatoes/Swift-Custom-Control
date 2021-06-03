// *******************************************
//  File Name:      BQDeviceAuth.swift       
//  Author:         MrBai
//  Created Date:   2021/6/2 5:52 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
import Contacts
import Photos

enum DeviceAuthType: Int {
    case camera = 0         // 相机 Privacy - Camera Usage Description
    case photo              // 相册 Privacy - Photo Library Usage Description
    case audio              // 麦克风 Privacy - Microphone Usage Description
    case contact            // 通讯录 Privacy - Contacts Usage Description
}

struct BQDeviceAuth {
    
    public static func authorization(type: DeviceAuthType, handle: @escaping (_ result: Bool) -> ()) {
        switch type {
        case .camera:
            cameraAuth(handle: handle)
            break
        case .photo:
            photoAuth(handle: handle)
            break
        case .audio:
            audioAuth(handle: handle)
            break
        case .contact:
            contactAuth(handle: handle)
            break
        }
    }
    
    private static func cameraAuth(handle: @escaping (_ result: Bool) -> ()) {
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
    
    private static func photoAuth(handle: @escaping (_ result: Bool) -> ()) {
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
    
    private static func audioAuth(handle: @escaping (_ result: Bool) -> ()) {
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
    
    private static func contactAuth(handle: @escaping (_ result: Bool) -> ()) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized {
            handle(true)
        } else if status == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) { result, error in
                handle(result)
            }
        } else {
            handle(false)
        }
    }
}
