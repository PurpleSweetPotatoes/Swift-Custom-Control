// *******************************************
//  File Name:      BQWebView.swift       
//  Author:         MrBai
//  Created Date:   2021/7/5 5:20 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
import WebKit

typealias ScriptBlock = (_ message: WKScriptMessage)->()

/// h5端js交互消息发送 window.webkit.messageHandlers.<注册的消息名称>.post
class BQWebView: WKWebView {

    //MARK: - *** Ivars
    let scriptObjc = WebScriptObjc()
    var cookScript: WKUserScript?
    var progressObserve: NSKeyValueObservation?
    var titleObserve: NSKeyValueObservation?
    
    //MARK: - *** Public method
    
    public func addScriptHandle(name: String, hanlde: @escaping ScriptBlock) {
        self.configuration.userContentController.add(scriptObjc, name: name)
        scriptObjc.msgBlocks[name] = hanlde
    }
    
    public func loadWebHeight(handle:@escaping (CGFloat, Error?) -> Void) {
        self.evaluateJavaScript("document.documentElement.scrollHeight") { objc, error in
            if let height = objc as? CGFloat {
                 handle(height, nil)
            } else {
                handle(0, error)
            }
        }
    }
    
    public func configProgressHandle(handle:@escaping (CGFloat) -> Void) {
        if let observe = progressObserve {
            observe.invalidate()
        }
        progressObserve = observe(\.estimatedProgress, options: [.new]) {item, value in
            if let num = value.newValue {
                handle(CGFloat(num))
            }
        }
    }
    
    public func configTitleHandle(handle:@escaping (String) -> Void) {
        if let observe = titleObserve {
            observe.invalidate()
        }
        titleObserve = observe(\.title, options: [.new]) {item, value in
            if let str = value.newValue, let outStr = str {
                handle(outStr)
            }
        }
    }
    
    public func loadImgsList(handle:@escaping (Array<String>) -> Void) {
        let jsGetImages = "function getImages(){ var objs = document.getElementsByTagName('img'); var imgScr = ''; for(var i=0;i<objs.length;i++){ imgScr = imgScr + objs[i].src; if (i + 1 < objs.length) { imgScr = imgScr + ' '}} return imgScr.split(' '); }; getImages()";
        evaluateJavaScript(jsGetImages) { result, error in
            if let arr = result as? Array<String> {
                handle(arr)
            }
        }
    }
    
    
    public func addCookies(cookies: [String:String]) {
        var list = configuration.userContentController.userScripts
        if let cook = cookScript,  let index = list.firstIndex(of:cook) {
            list.remove(at: index)
            configuration.userContentController.removeAllUserScripts()
            for script in list {
                configuration.userContentController.addUserScript(script)
            }
        }
        var cookieStr = ""
        for key in cookies.keys {
            cookieStr = "\(cookieStr)document.cookie='\(key)=\(String(describing: cookies[key]))';"
        }
        cookScript = WKUserScript(source: cookieStr, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(cookScript!)
        for script in configuration.userContentController.userScripts {
            BQLogger.log("===\(script.source)")
        }
    }
    
    //MARK: - *** Life cycle
    
    deinit {
        
        for name in scriptObjc.msgBlocks.keys {
            self.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
        
        if let observe = progressObserve {
            observe.invalidate()
        }
        
        if let observe = titleObserve {
            observe.invalidate()
        }
    }
    
    //MARK: - *** Event Action
    
    //MARK: - *** Delegate

    //MARK: - *** Instance method
    
    //MARK: - *** UI method

}

@available(iOS 11.0, *)
extension BQWebView: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        BQLogger.log("开始请求");
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        BQLogger.log("完成请求");
    }
    
}

class WebScriptObjc: NSObject, WKScriptMessageHandler {
    
    deinit {
        BQLogger.log("\(self) 释放")
    }
    
    var msgBlocks = [String: ScriptBlock]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let block = msgBlocks[message.name] {
            block(message)
        }
    }
    
}


extension WKWebView {
    
    @discardableResult
    func load(_ urlStr: String) -> WKNavigation? {
        if let url = URL(string: urlStr) {
            return load(URLRequest(url: url))
        }
        return nil
    }
    
    /// 文本大小自适应
    func textAutoFit() {
        let textJs = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        addJs(js: textJs, time: .atDocumentEnd)
    }
    
    /// 图片宽度自适应
    /// - Parameter space: 图片与父视图的左右间距
    func imgAutoFit(space: CGFloat = 10) {
        let imgJs = String(format: "function imgAutoFit() { var imgs = document.getElementsByTagName('img'); for (var i = 0; i < imgs.length; ++i) { var img = imgs[i]; img.style.maxWidth = %f; } }", space)
        addJs(js: imgJs, time: .atDocumentEnd)
        
    }
    
    /// 注入js代码
    ///
    /// - Parameters:
    ///   - js: js代码
    ///   - time: 执行时间
    func addJs(js: String, time: WKUserScriptInjectionTime) {
        let textScript = WKUserScript(source: js, injectionTime: time, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(textScript)
    }
}
