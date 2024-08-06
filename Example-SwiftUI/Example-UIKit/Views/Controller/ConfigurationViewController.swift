//
//  ConfigurationViewController.swift
//
//  Created by Ashok Singh on 15/04/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {

    @IBOutlet var switchDefault : UISwitch!
    @IBOutlet var switchScreenTracking : UISwitch!
    @IBOutlet var switchANR : UISwitch!
    @IBOutlet var switchMemoryWorning : UISwitch!
    @IBOutlet var switchNetworkMonitor : UISwitch!
    @IBOutlet var switchCrash : UISwitch!
    @IBOutlet var switchNetworkSampleRate : UISwitch!
    @IBOutlet var switchNetworkState : UISwitch!
    
    @IBOutlet var switchLaunchTime : UISwitch!
    @IBOutlet var switchConfigOnLaunch : UISwitch!
    @IBOutlet var switchAddDelay : UISwitch!
    
    @IBOutlet var btnApply : UIButton!
    @IBOutlet var btnCancel : UIButton!
    
    private let vm =  ConfigurationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadConfiguration()
    }
    
    func loadConfiguration(){
        
        btnApply.accessibilityIdentifier = "configure_apply"
        btnCancel.accessibilityIdentifier = "configure_cancel"
        
        switchDefault.isOn = vm.isConfigDefault
        switchDefault.accessibilityIdentifier = "switch_default"
        
        switchScreenTracking.isOn = vm.isScreenTracking
        switchScreenTracking.accessibilityIdentifier = "switch_screen_tracking"
        
        switchANR.isOn = vm.isANR
        switchANR.accessibilityIdentifier = "switch_ANR"
        
        switchMemoryWorning.isOn = vm.isMemoryWarning
        switchMemoryWorning.accessibilityIdentifier = "switch_memory_warning"
        
        switchNetworkMonitor.isOn = vm.isPerfomanceMonitor
        switchNetworkMonitor.accessibilityIdentifier = "switch_network_monitor"
        
        switchCrash.isOn = vm.isCrashTracking
        switchCrash.accessibilityIdentifier = "switch_crash"
        
        switchNetworkSampleRate.isOn = vm.isNetworkSampleRate
        switchNetworkSampleRate.accessibilityIdentifier = "switch_network_sample_rate"
        
        switchNetworkState.isOn = vm.isNetworkState
        switchNetworkState.accessibilityIdentifier = "switch_network_state"
        
        switchLaunchTime.isOn = vm.isLaunchTime
        switchLaunchTime.accessibilityIdentifier = "switch_launch_time"
        
        switchConfigOnLaunch.isOn = vm.isConfigOnLaunchTime
        switchConfigOnLaunch.accessibilityIdentifier = "switch_config_on_launch"
        
        switchAddDelay.isOn = vm.isAddDelayKey
        switchAddDelay.accessibilityIdentifier = "switch_add_delay"
        
        switchScreenTracking.isEnabled = !vm.isConfigDefault
        switchANR.isEnabled = !vm.isConfigDefault
        switchMemoryWorning.isEnabled = !vm.isConfigDefault
        switchNetworkMonitor.isEnabled = !vm.isConfigDefault
        switchCrash.isEnabled = !vm.isConfigDefault
        switchNetworkSampleRate.isEnabled = !vm.isConfigDefault
        switchNetworkState.isEnabled = !vm.isConfigDefault
        switchLaunchTime.isEnabled = !vm.isConfigDefault
    }

    @IBAction func didSelectDone(_ sender: Any?) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didSelectApply(_ sender: Any?) {
        self.vm.applyChanges()
        exit(0)
    }
    
    @IBAction func didChangeSwitch(_ sender: UISwitch?) {
        
        if let sender = sender{
            if sender == switchDefault{
                vm.updateDefaultConfig(sender.isOn)
                self.loadConfiguration()
            }else if  sender == switchScreenTracking{
                vm.updateScreenTrackingConfig(sender.isOn)
            }else if  sender == switchANR{
                vm.updateANRConfig(sender.isOn)
            }else if  sender == switchMemoryWorning{
                vm.updateMemoryWarningConfig(sender.isOn)
            }else if  sender == switchNetworkMonitor{
                vm.updatePerfomanceMonitorConfig(sender.isOn)
            }else if  sender == switchCrash{
                vm.updateCrash(sender.isOn)
            }else if  sender == switchNetworkSampleRate{
                vm.updateNetworkSampleRate(sender.isOn)
            }else if  sender == switchNetworkState{
                vm.updateNetworkState(sender.isOn)
            }else if  sender == switchLaunchTime{
                vm.updateLaunchTime(sender.isOn)
            }else if  sender == switchConfigOnLaunch{
                vm.updateConfigOnLaunch(sender.isOn)
            }else if  sender == switchAddDelay{
                vm.updateAddDelay(sender.isOn)
            }
        }
    }
}
