// *******************************************
//  File Name:      UIScreen+Custom.swift       
//  Author:         MrBai
//  Created Date:   2021/7/30 3:12 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

extension UIScreen {
    
    static public var width: CGFloat {
        get { return self.main.bounds.width }
    }
    
    static public var height: CGFloat {
        get { return self.main.bounds.height }
    }

}
