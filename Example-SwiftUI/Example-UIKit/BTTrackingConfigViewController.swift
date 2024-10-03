//
//  BTTrackingConfigViewController.swift
//
//  Created by Ashok Singh on 27/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

class BTTrackingConfigViewController: UIViewController {

    @IBOutlet weak var txtSiteID : UITextField!
    @IBOutlet weak var txtSessionID : UITextField!
    @IBOutlet weak var anrEnableSwitch : UISwitch!
    @IBOutlet weak var screenTrackEnableSwitch : UISwitch!
    @IBOutlet weak var anrStackTraceSwitch : UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtSiteID.text = Secrets.siteID
        self.txtSessionID.text = self.getSessionId()
        btnSetup()
    }
    
    func btnSetup() {
        self.btnSave.layer.cornerRadius = 8
    }

    
    @IBAction func didSelectConfig(_ sender: Any?) {
        
        guard let siteId = self.txtSiteID.text?.trimmingCharacters(in: .whitespaces), siteId.count > 0 else{
            return
        }
        
        var identifierSessionId  : Identifier = 0
        
        UserDefaults.standard.set(anrEnableSwitch.isOn, forKey: UserDefaultKeys.ANREnableKey)
        UserDefaults.standard.set(screenTrackEnableSwitch.isOn, forKey: UserDefaultKeys.ScreenTrackingEnableKey)
        UserDefaults.standard.set(siteId, forKey: UserDefaultKeys.ConfigureSiteId)
        UserDefaults.standard.set(anrStackTraceSwitch.isOn, forKey: UserDefaultKeys.ANRStackTraceKey)

        if let sessionId = self.txtSessionID.text?.trimmingCharacters(in: .whitespaces), sessionId.count > 0{
            identifierSessionId = Identifier(sessionId) ?? 0
            UserDefaults.standard.set(sessionId, forKey: UserDefaultKeys.ConfigureSessionId)
        }
        else{
            UserDefaults.standard.removeObject(forKey:UserDefaultKeys.ConfigureSessionId)
        }
        UserDefaults.standard.synchronize()
        
        BlueTriangle.configure { config in
            config.siteID = siteId
            config.networkSampleRate = 1.0
            config.crashTracking = .nsException
            config.enableDebugLogging = true
            config.enableScreenTracking = screenTrackEnableSwitch.isOn
            config.ANRMonitoring = anrEnableSwitch.isOn
            config.ANRStackTrace = anrStackTraceSwitch.isOn
        }
        
        AppCoordinator.setupRootTabVc()
    }
    
    func getSessionId() -> String{
        let formatter = DateFormatter()
        
       // YYYYMMDDhhmm
        formatter.dateFormat = "YYYYMMddhhmm"
        let value = formatter.string(from: Date())
        return value
    }
    
    @IBAction func didChangeANRSwitch(_ sender: Any?) {
    }
    
    @IBAction func didChangeScreenTrackSwitch(_ sender: Any?) {
    }
}
