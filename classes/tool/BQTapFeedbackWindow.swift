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
    private let firstTapView = UIView()
    private let secondTapView = UIView()

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if subviews.last != secondTapView {
            bringSubviewToFront(firstTapView)
            bringSubviewToFront(secondTapView)
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        clear()
        self.event = event
        resetDisplayLink()
        return super.hitTest(point, with: event)
    }
}

private extension BQTapFeedbackWindow {

    func resetDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(eventProcessHandle))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    func clearDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func clear() {
        event = nil
        clearDisplayLink()
        UIView.animate(withDuration: 0.15) {
            self.firstTapView.alpha = 0
            self.secondTapView.alpha = 0
        }
    }

    @objc private func eventProcessHandle() {
        print("eventProcessHandle")
        guard let allTouches = self.event?.allTouches,
              !allTouches.isEmpty,
              let firstTouch = allTouches.first else {
            clear()
            return
        }
        processTouchDisplay(with: firstTouch, displayView: firstTapView)
        if allTouches.count == 2,
           let secondTouch = Array(allTouches).last {
            processTouchDisplay(with: secondTouch, displayView: secondTapView)
        } else if secondTapView.alpha != 0 {
            UIView.animate(withDuration: 0.15) {
                self.secondTapView.alpha = 0
            }
        }
    }

    private func processTouchDisplay(with touch: UITouch, displayView: UIView) {
        if let currentWindow = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last {
            let point = touch.location(in: currentWindow)
            switch touch.phase {
            case .began, .moved, .stationary:
                displayView.alpha = 1
                displayView.center = point
            default:
                UIView.animate(withDuration: 0.15) {
                    displayView.alpha = 0
                }
            }
        }
    }

    private func setupUI() {
        configTapView(with: firstTapView)
        configTapView(with: secondTapView)
    }

    private func configTapView(with tapView: UIView) {
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
