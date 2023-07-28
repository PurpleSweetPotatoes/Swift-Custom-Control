//
//  UIControl+Combine.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/3/17.
//  Copyright © 2023 Garmin All rights reserved
//  

import Combine
import Foundation

public extension UIControl {
    @discardableResult
    func publisher(for events: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        UIControlPublisher(control: self, events: events).eraseToAnyPublisher()
    }
}

struct UIControlPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let controlEvents: Control.Event

    init(control: Control, events: Control.Event) {
        self.control = control
        self.controlEvents = events
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

/// A custom subscription to capture UIControl target events.
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    deinit {
        BQLogger.debug("释放 Subscription")
    }

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

