//
//  Constants.swift
//  Example-SwiftUI
//
//  Created by Mathew Gacy on 10/19/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Foundation

enum Constants {
    static let averageSalesTax: Double = 0.0635
    static let currencyCode = "USD"
    static let shipping = "3.99"
}
extension Double {
    /// Rounds the double to decimal places value
    func roundedToPlaces(places: Int = 2) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct UserDefaultKeys {
    static let ANREnableKey = "ANREnableKey"
    static let ScreenTrackingEnableKey = "ScreenTrackingEnableKey"
    static let ConfigureSiteId = "ConfigureSiteId"
    static let ConfigureSessionId = "ConfigureSessionId"
    static let ANRStackTraceKey = "ANRStackTraceKey"
    static let TutorialShownKey = "TutorialShownKey"
}
