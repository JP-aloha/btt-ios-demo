//
//  ConfigurationSetup.swift
//
//  Created by Ashok Singh on 09/05/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import BlueTriangle
import Foundation

class ConfigurationSetup {

    static func configOnLaunch(){
        ConfigurationModel.setupInitialDefaultConfiguration()
        let isCofigOnLaunchTime = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigOnLaunchTimeKey)
        if isCofigOnLaunchTime {
            configure()
        }
    }
    
    static func configOnOtherScreen(){
        ConfigurationModel.setupInitialDefaultConfiguration()
        let isCofigOnLaunchTime = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigOnLaunchTimeKey)
        if !isCofigOnLaunchTime {
            configure()
        }
    }
    
    static func configure(){

        let isDefaultSetting = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigDefaultKey)
        let enableScreenTracking = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
        let anrMonitoring =  UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigANRKey)
        let enableMemoryWarning = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigMemoryWarningKey)
        let isPerformanceMonitor = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigPerfomanceMonitorKey)
        let isCrashTracking = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigCrashKey)
        let isNetworkState = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigNetworkStateKey)
        let isNetworkSampleRate = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigNetworkSampleRateKey)
        let isLaunchTime = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigLaunchTimeKey)
        
        let siteId = Secrets.siteID
        let enableDebugLogging = true
        let enableAnrStackTrace = false
        
        UserDefaults.standard.set(anrMonitoring, forKey: UserDefaultKeys.ANREnableKey)
        UserDefaults.standard.set(enableScreenTracking, forKey: UserDefaultKeys.ScreenTrackingEnableKey)
        UserDefaults.standard.set(siteId, forKey: UserDefaultKeys.ConfigureSiteId)
        UserDefaults.standard.set(enableAnrStackTrace, forKey: UserDefaultKeys.ANRStackTraceKey)

        
        BlueTriangle.configure { config in
            config.siteID = siteId
            config.enableDebugLogging = enableDebugLogging
            if !isDefaultSetting {
                config.networkSampleRate = isNetworkSampleRate ? 1.0 : 0.00
                config.crashTracking = isCrashTracking ? .nsException : .none
                config.enableScreenTracking = enableScreenTracking
                config.ANRMonitoring = anrMonitoring
                config.ANRStackTrace = enableAnrStackTrace
                config.enableMemoryWarning = enableMemoryWarning
                config.enableTrackingNetworkState = isNetworkState
                config.isPerformanceMonitorEnabled = isPerformanceMonitor
                config.cacheMemoryLimit = 20 * 1024
                config.cacheExpiryDuration = 5 * 60 * 1000
                config.enableLaunchTime = isLaunchTime
            }
        }
        
        let sessionId = "\(BlueTriangle.sessionID)"
        UserDefaults.standard.set(sessionId, forKey: UserDefaultKeys.ConfigureSessionId)
        UserDefaults.standard.synchronize()
    }

    static func addDelay(){
        let isDelay = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigAddDelayKey)
        if isDelay {
            let startTime = Date()
            while true {
                if (Date().timeIntervalSince1970 - startTime.timeIntervalSince1970) > 3 {
                    break
                }
            }
        }
    }
}


class SessionData: Codable {
    var sessionID: Identifier
    var expiration: Millisecond

    init(sessionID: Identifier, expiration: Millisecond) {
        self.sessionID = sessionID
        self.expiration = expiration
    }
}

class SessionStore {
    
    private static let sessionKey = "SAVED_SESSION_DATA"
    
    static func updateSessionExpiry(){
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if let session = retrieveSessionData() {
                session.expiration = expiryDuration()
                self.saveSession(session)
                print("Save session: \(session.sessionID)---\(session.expiration)")
            }
        }
    }
    
    private static func saveSession(_ session: SessionData) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: sessionKey)
        }
    }
    
    private static func retrieveSessionData() -> SessionData? {
        if let savedSession = UserDefaults.standard.object(forKey: sessionKey) as? Data {
            if let decodedSession = try? JSONDecoder().decode(SessionData.self, from: savedSession) {
                return decodedSession
            }
        }
        return nil
    }
    
    private static func expiryDuration()-> Millisecond {
        let expiry = (Int64(Date().timeIntervalSince1970) * 1000) + (2 * 60 * 1000)
        return expiry
    }
}
