// *******************************************
//  File Name:      BQSheetView.swift
//  Author:         MrBai
//  Created Date:   2019/8/20 3:58 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

class BQHudView: UIView {
    private var titleFont = UIFont.systemFont(ofSize: 16)
    private var title: String?
    private var info: String!
    private var infoFont = UIFont.systemFont(ofSize: 14)

    @discardableResult
    public class func show(supView: UIView, animation _: Bool? = true, title: String? = nil) -> BQHudView {
        if let hudView = self.hudView(supView: supView) {
            hudView.removeFromSuperview()
        }

        let hudView = BQHudView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        hudView.title = title
        hudView.setUpUI()
        hudView.center = CGPoint(x: supView.sizeW * 0.5, y: supView.sizeH * 0.5)
        supView.addSubview(hudView)
        return hudView
    }

    public class func hide(supView: UIView, animation: Bool? = true) {
        if let hudView = self.hudView(supView: supView) {
            hudView.hide(animation: animation)
        }
    }

    public class func hudView(supView: UIView) -> BQHudView? {
        for view in supView.subviews.reversed() {
            if view is BQHudView {
                return view as? BQHudView
            }
        }

        return nil
    }

    public class func show(_ info: String, title: String? = nil) {
        if info.count == 0 { return }

        let msgView = BQHudView(frame: UIScreen.main.bounds, info: info, title: title)

        if let hudView = self.hudView(supView: UIApplication.shared.keyWindow!) {
            hudView.removeFromSuperview()
        } else {
            msgView.alpha = 0
            UIView.animate(withDuration: 0.25) {
                msgView.alpha = 1
            }
        }

        msgView.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)
        UIApplication.shared.keyWindow?.addSubview(msgView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            msgView.removeFromSuperview()
        }
    }

    private convenience init(frame: CGRect, info: String, title: String?) {
        self.init(frame: frame)
        self.info = info
        self.title = title
        createContentView()
    }

    // MARK: - ***** instance method *****

    public func setUpUI() {
//        self.backgroundColor = UIColor("e3e7e7")
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        layer.cornerRadius = 8

        let activiView = UIActivityIndicatorView(style: .white)
        activiView.startAnimating()
        activiView.center = CGPoint(x: sizeW * 0.5, y: sizeH * 0.5)
        activiView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        addSubview(activiView)

        if let text = title {
            let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 20))
            lab.font = infoFont
            lab.textColor = .white
            lab.text = text
            lab.numberOfLines = 0
            let rect = lab.adjustHeight(spacing: 10)

            lab.sizeW = rect.size.width
            addSubview(lab)

            if sizeW < lab.sizeW + 40 {
                sizeW = lab.sizeW + 40
            }

            if sizeH < lab.sizeH + activiView.sizeH + 20 {
                sizeH = lab.sizeH + activiView.sizeH + 20
            }

            activiView.center = CGPoint(x: sizeW * 0.5, y: sizeH * 0.5)
            lab.center = activiView.center
            activiView.top -= lab.sizeH * 0.5
            lab.top = activiView.bottom + 5
        }
    }

    public func hide(animation: Bool? = true) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = (animation! ? 0 : 1)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    private func createContentView() {
        backgroundColor = UIColor(white: 0, alpha: 0.8)
        let width = sizeW - 100
        var titleLab: UILabel?
        var maxWidth: CGFloat = 0

        if let title = self.title {
            let rect = title.boundingRect(with: CGSize(width: width, height: 100), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: titleFont], context: nil)
            let lab = UILabel(frame: rect)
            lab.numberOfLines = 0
            lab.font = UIFont.systemFont(ofSize: 16)
            lab.textColor = UIColor.white
            lab.text = title
            addSubview(lab)
            titleLab = lab
            maxWidth = lab.sizeW
        }

        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        let dic = [NSAttributedString.Key.font: infoFont,
                   NSAttributedString.Key.paragraphStyle: style]
        let infoRect = info.boundingRect(with: CGSize(width: max(maxWidth, width), height: 100), options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], attributes: dic, context: nil)

        let contentLab = UILabel(frame: infoRect)
        contentLab.numberOfLines = 0
        contentLab.lineBreakMode = .byCharWrapping
        contentLab.font = infoFont
        contentLab.text = info
        contentLab.textColor = UIColor.white
        addSubview(contentLab)
        sizeW = max(maxWidth, contentLab.sizeW) + 40

        if let lab = titleLab {
            sizeH = lab.sizeH + contentLab.sizeH + 50
            lab.center = CGPoint(x: sizeW * 0.5, y: 20 + lab.sizeH * 0.5)
            contentLab.center = CGPoint(x: sizeW * 0.5, y: lab.bottom + 10 + contentLab.sizeH * 0.5)
        } else {
            sizeH = contentLab.sizeH + 40
            contentLab.center = CGPoint(x: sizeW * 0.5, y: 20 + contentLab.sizeH * 0.5)
        }
        setCorner(readius: 8)
    }
}
