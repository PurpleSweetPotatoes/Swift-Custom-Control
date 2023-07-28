//
//  BQTapFeedbackWindow.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/6/2.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

public class TapFeedbackManager: NSObject {
    public static var feedbackWindow: BQTapFeedbackWindow?

    public static func addFeedBackWindow() {
        guard let windowScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene>,
              let currentScene = windowScenes.first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) else {
            return
        }
        Self.feedbackWindow = BQTapFeedbackWindow(windowScene: currentScene)
        Self.feedbackWindow?.windowLevel = UIWindow.Level.alert + 1
        Self.feedbackWindow?.isHidden = false
    }
}

public final class BQTapFeedbackWindow: UIWindow {
    private var event: UIEvent?
    private var displayLink: CADisplayLink?
    private let firstTapView = UIView()
    private let secondTapView = UIView()

    private final class FeedbackViewController: UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .darkContent
        }
    }

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        rootViewController = FeedbackViewController()
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
            self.firstTapView.alpha = 0
            self.secondTapView.alpha = 0
        }
    }

    @objc private func eventProcessHandle() {
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
        rootViewController?.view.backgroundColor = .clear
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
        rootViewController?.view.addSubview(tapView)
    }
}
