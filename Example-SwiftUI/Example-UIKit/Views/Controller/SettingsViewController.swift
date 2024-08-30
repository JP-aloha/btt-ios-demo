//
//  SettingsViewController.swift
//
//  Created by Admin on 22/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

class SettingsViewController: UIViewController {

    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var lblSdkVersionRule: UILabel!
    @IBOutlet weak var lblSdkLocation: UILabel!
    @IBOutlet weak var lblSiteId: UILabel!
    @IBOutlet weak var lblSessionId: UILabel!
    @IBOutlet weak var lblPlateform: UILabel!
    @IBOutlet weak var lblClaritySessionId: UILabel!
    
    @IBOutlet weak var lblAnrEnable : UILabel!
    @IBOutlet weak var lblScreenTrackEnable : UILabel!
    @IBOutlet weak var lblAnrStackTraceEnable : UILabel!
    @IBOutlet weak var btnConfigurationSettings : UIButton!
    
    private var tagUrl = "\(Secrets.siteID).btttag.com/btt.js"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblPlateform.text = "This app is built with UIKit."
        lblAnrEnable.text = UserDefaults.standard.bool(forKey: UserDefaultKeys.ANREnableKey) ? "Enable" : "Disable"
        lblScreenTrackEnable.text = UserDefaults.standard.bool(forKey: UserDefaultKeys.ScreenTrackingEnableKey)  ? "Enable" : "Disable"
        lblAnrStackTraceEnable.text = UserDefaults.standard.bool(forKey: UserDefaultKeys.ANRStackTraceKey) ? "Enable" : "Disable"
        lblSiteId.text = UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSiteId) ?? ""
        lblAppVersion.text = "\(version())"
        lblSdkVersionRule.text = "feature/cpu-memory-netstate-offline-hybrid"//"master"
        lblSdkLocation.text = "http://github.com/JP-aloha/btt-swift-sdk.git"
        lblSessionId.text = UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSessionId) ?? "Auto Generated"
        lblSessionId.accessibilityIdentifier = "btt session id"
        btnConfigurationSettings.accessibilityIdentifier = "btn_configuration_settings"
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.lblSessionId.text =  UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSessionId) ?? "Auto Generated"
        }
    }
    
    @IBAction func btnTestManualTimer(_ sender: UIButton) {
        
        if BlueTriangle.initialized {
            let timer = BlueTriangle.startTimer(
                page: Page(
                    pageName: "TEST MANUAL TIMER"))
            BlueTriangle.endTimer(timer)
        }
    }
    
    @IBAction func didSelectMemoryTest(_ sender: Any?) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        guard let itemVC = storyboard.instantiateViewController(withIdentifier: "UnitTestsViewController") as? UnitTestsViewController else { return }
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    @IBAction func didSelectWebView(_ sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigation = storyboard.instantiateViewController(identifier: "WebViewNav") as? UINavigationController, let vc = navigation.viewControllers.first as? BttWebViewController{
            navigation.modalPresentationStyle = .fullScreen
            vc.tagUrl = tagUrl
            self.present(navigation, animated: true)
        }
    }
    
    @IBAction func didSelectSessionIDCopy(_ sender: Any?) {
        UIPasteboard.general.string = UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSessionId)
    }
    
    @IBAction func didSelectClaritySessionIDCopy(_ sender: Any?) {
        UIPasteboard.general.string = UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSessionId)
    }
    
    @IBAction func didSelectSetting(_ sender: Any?) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = self.tagUrl
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let textFieldValue = alert?.textFields![0].text{
                self.tagUrl = textFieldValue
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didSelectConfiguration(_ sender: Any?) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(identifier: "ConfigurationViewController") as? ConfigurationViewController{
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func didSelectSignalCrash(_ sender: Any?) {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(identifier: "SignalCrashView") as? SignalCrashViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(build))"
    }

}
