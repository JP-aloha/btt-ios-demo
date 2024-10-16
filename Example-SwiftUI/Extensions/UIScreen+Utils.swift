//
//  UIScreen+Utils.swift
//
//  Created by Ashok Singh on 15/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
    
    private static func resolution() -> CGSize{
        let screenSize = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let screenResolution = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
        return screenResolution
    }
    
    static func resolutionHeight() -> Double{
        return resolution().height
    }
    
    static func resolutionWidth() -> Double{
        return resolution().width
    }
}
