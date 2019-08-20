// *******************************************
//  File Name:      WKWebView+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/19 9:53 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import WebKit

extension WKWebView {
    
    /// 文本大小自适应
    func textAutoFit() {
        let textJs = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        self.addJs(js: textJs, time: .atDocumentEnd)
    }
    
    /// 图片宽度自适应
    /// - Parameter space: 图片与父视图的左右间距
    func imgAutoFit(space: CGFloat = 10) {
        let imgJs = String(format: "function imgAutoFit() { var imgs = document.getElementsByTagName('img'); for (var i = 0; i < imgs.length; ++i) { var img = imgs[i]; img.style.maxWidth = %f; } }", space)
        self.addJs(js: imgJs, time: .atDocumentEnd)
    }
    
    /// 注入js代码
    ///
    /// - Parameters:
    ///   - js: js代码
    ///   - time: 执行时间
    func addJs(js: String, time: WKUserScriptInjectionTime) {
        let textScript = WKUserScript(source: js, injectionTime: time, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(textScript)
    }

}
