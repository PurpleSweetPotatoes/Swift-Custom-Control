//
//  BQTapFeedbackWindow.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/6/2.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

public final class BQTapFeedbackWindow: UIWindow {
    private var event: UIEvent?
    private var displayLink: CADisplayLink?
    private let tapView = UIView()

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        clear()
        self.event = event
        resetDisplayLink()
        return nil
    }

    private func resetDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(eventProcessHandle))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    private func clearDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func clear() {
        event = nil
        clearDisplayLink()
        UIView.animate(withDuration: 0.15) {
            self.tapView.alpha = 0
        }
    }

    @objc private func eventProcessHandle() {
        guard let allTouches = self.event?.allTouches,
              !allTouches.isEmpty else {
            clear()
            return
        }
        if let touch = allTouches.first,
           let currentWindow = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            let point = touch.location(in: currentWindow)
            switch touch.phase {
            case .began, .moved, .stationary:
                tapView.alpha = 1
                tapView.center = point
            default:
                UIView.animate(withDuration: 0.15) {
                    self.tapView.alpha = 0
                }
            }
        }
    }

    private func setupUI() {
        tapView.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        tapView.backgroundColor = UIColor(white: 0.7, alpha: 0.4)
        tapView.layer.cornerRadius = 20
        tapView.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 0.5).cgColor
        tapView.layer.borderWidth = 2
        tapView.isUserInteractionEnabled = false
        tapView.clipsToBounds = true
        tapView.alpha = 0
        addSubview(tapView)
    }
}
