//
//  BQNsck.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/5/6.
//  Copyright © 2023 Garmin All rights reserved
//  

import Combine
import Network

// 网络状态检查 network state check

/**
 var sb = Set<AnyCancellable>()
 var alertMsg = ""

 Nsck.shared.pb
     .sink { _ in
         //
     } receiveValue: { path in
         alertMsg = path.debugDescription
         switch path.status {
         case .satisfied:
             alertMsg = ""
         case .unsatisfied:
             alertMsg = "😱"
         case .requiresConnection:
             alertMsg = "🥱"
         @unknown default:
             alertMsg = "🤔"
         }
         if path.status == .unsatisfied {
             switch path.unsatisfiedReason {
             case .notAvailable:
                 alertMsg += "网络不可用"
             case .cellularDenied:
                 alertMsg += "蜂窝网不可用"
             case .wifiDenied:
                 alertMsg += "Wifi不可用"
             case .localNetworkDenied:
                 alertMsg += "网线不可用"
             @unknown default:
                 alertMsg += "网络不可用"
             }
         }
     }
     .store(in: &sb)
 */
final class BQNsck: ObservableObject {
    static let shared = BQNsck()
    private(set) lazy var pb = mkpb()
    @Published private(set) var pt: NWPath

    private let monitor: NWPathMonitor
    private lazy var sj = CurrentValueSubject<NWPath, Never>(monitor.currentPath)
    private var sb: AnyCancellable?

    init() {
        monitor = NWPathMonitor()
        pt = monitor.currentPath
        monitor.pathUpdateHandler = { [weak self] path in
            self?.pt = path
            self?.sj.send(path)
        }
        monitor.start(queue: DispatchQueue.global())
    }

    deinit {
        monitor.cancel()
        sj.send(completion: .finished)
    }

    private func mkpb() -> AnyPublisher<NWPath, Never> {
        return sj.eraseToAnyPublisher()
    }
}
