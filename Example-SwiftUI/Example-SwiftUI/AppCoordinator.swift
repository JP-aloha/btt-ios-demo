//
//  AppCoordinator.swift
//
//  Created by Ashok Singh on 07/08/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import Foundation
import Combine
import BlueTriangle

class AppCoordinator: ObservableObject {
    @Published var isShownTutorial : Bool =  Foundation.UserDefaults.standard.bool(forKey: UserDefaultKeys.TutorialShownKey)
}
