//
//  ConfigurationView.swift
//
//  Created by Ashok Singh on 16/04/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import SwiftUI

struct ConfigurationView: View {
    
    @Binding var isConfigurationActive : Bool
    @ObservedObject var vm : ConfigurationModel  
    @State private var showConfirm = false
    
    var body: some View {
        HStack{
            VStack(spacing: 10) {
                
                VStack{
                    HStack{
                        Button("Cancel") {
                            isConfigurationActive = false
                        }.accessibilityIdentifier("configure_cancel")
                        Spacer()
                        Text("Configuration")
                            .font(Font.system(size: 18, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        Button("Apply") {
                            vm.applyChanges()
                            exit(0)
                        }.accessibilityIdentifier("configure_apply")
                    }
                }
                .frame(height: 50)
                
                VStack{
                    HStack{
                        Text("Kepp Default Configurations")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isConfigDefault)
                            .onChange(of: self.vm.isConfigDefault, perform: { value in
                                vm.updateDefaultConfig(value)
                            }).accessibilityIdentifier("switch_default")
                    }
                }
                .frame(height: 100)
                
                VStack{
                    HStack{
                        Text("Screen Tracking")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isScreenTracking)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isScreenTracking, perform: { value in
                                vm.updateScreenTrackingConfig(value)
                            }).accessibilityIdentifier("switch_screen_tracking")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Perfomance Monitoring")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isPerfomanceMonitor)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isPerfomanceMonitor, perform: { value in
                                vm.updatePerfomanceMonitorConfig(value)
                            }).accessibilityIdentifier("switch_network_monitor")
                    }
                }
                .frame(height: 30)
                
                
                VStack{
                    HStack{
                        Text("Crash Tracking")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isCrashTracking)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isCrashTracking, perform: { value in
                                vm.updateCrash(value)
                            }).accessibilityIdentifier("switch_crash")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("ANR Tracking")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isANR)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isANR, perform: { value in
                                vm.updateANRConfig(value)
                            }).accessibilityIdentifier("switch_ANR")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Memory Warning")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isMemoryWarning)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isMemoryWarning, perform: { value in
                                vm.updateMemoryWarningConfig(value)
                            }).accessibilityIdentifier("switch_memory_warning")
                    }
                }
                .frame(height: 30)


                VStack{
                    HStack{
                        Text("Network Capturing")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isNetworkSampleRate)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isNetworkSampleRate, perform: { value in
                                vm.updateNetworkSampleRate(value)
                            }).accessibilityIdentifier("switch_network_sample_rate")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Network State Tracking")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isNetworkState)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isNetworkState, perform: { value in
                                vm.updateNetworkState(value)
                            }).accessibilityIdentifier("switch_network_state")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Launch Time")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isLaunchTime)
                            .disabled(vm.isConfigDefault)
                            .onChange(of: self.vm.isLaunchTime, perform: { value in
                                vm.updateLaunchTime(value)
                            }).accessibilityIdentifier("switch_launch_time")
                    }
                }
                .frame(height: 30)
                
                
                Spacer().frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Early Configuration")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isConfigOnLaunchTime)
                            .onChange(of: self.vm.isConfigOnLaunchTime, perform: { value in
                                vm.updateConfigOnLaunch(value)
                            }).accessibilityIdentifier("switch_config_on_launch")
                    }
                }
                .frame(height: 30)
                
                VStack{
                    HStack{
                        Text("Add Artificial Delay")
                            .font(Font.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Toggle("", isOn: $vm.isAddDelayKey)
                            .onChange(of: self.vm.isAddDelayKey, perform: { value in
                                vm.updateAddDelay(value)
                            }).accessibilityIdentifier("switch_add_delay")
                    }
                }
                .frame(height: 30)
                
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        //.alert(isPresented: $showConfirm, content: { confirmChange })
    }
    
    var confirmChange: Alert {
        Alert(title: Text("Change Configuration?"), message: Text("This application needs to restart to update the configuration. Do you want to restart the application?"),
              primaryButton: .default (Text("Yes")) {
            vm.applyChanges()
            showConfirm = true
        },
              secondaryButton: .cancel(Text("No"))
        )
    }
}

#Preview {
    ConfigurationView(isConfigurationActive: .constant(true), vm: ConfigurationModel())
}
