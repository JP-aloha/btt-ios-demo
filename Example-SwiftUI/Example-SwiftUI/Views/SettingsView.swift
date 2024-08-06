//
//  SettingsView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import BlueTriangle
import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: SettingsViewModel
    @State var isUnitTestsActive : Bool = false
    @State private var showingAlert = false
    @State private var showModal = false
    @State private var presentHybridDemo = false
    @State private var tagUrl = "\(Secrets.siteID).btttag.com/btt.js"
    
    var body: some View {
        NavigationStack {
        
            VStack(spacing: 5){
                
                VStack{
                    HStack{
                        Spacer()
                        Image("settingAppIcon")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Spacer()
                    }
                }
                .frame(height: 80)
                
                VStack{
                    HStack{
                        Spacer()
                        Text("BTT e-Com")
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("This app is built with swiftUI.")
                            .italic(true)
                            .font(Font.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Spacer()
                        Text("Version")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("\(version())")
                            .font(Font.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .frame(height: 50)
                
                Spacer()
                        .frame(height: 50)
                
                VStack{
                    HStack{
                        Text("Site Id")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    HStack{
                        Text(vm.configureSiteId)
                            .font(Font.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .frame(height: 50)
                
                VStack{
                    VStack{
                        HStack{
                            Text("Session Id")
                                .font(Font.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Button {
                                UIPasteboard.general.string = vm.configureSessionId
                            } label: {
                                Text("Copy")
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 10)
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            Spacer()
                        }
                        
                        HStack{
                            Text(vm.configureSessionId)
                                .font(Font.system(size: 18, weight: .regular))
                                .foregroundColor(.gray)
                                .accessibilityIdentifier("btt session id")
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    
                    Spacer()
                            .frame(height: 15)
                }
                
                Spacer()
                        .frame(height: 50)
                
                VStack(spacing: 10){
                    HStack{
                        
                        Button("TEST MANUAL TIMER") {
                            if BlueTriangle.initialized {
                                let timer = BlueTriangle.startTimer(
                                    page: Page(
                                        pageName: "TEST MANUAL TIMER"))
                                BlueTriangle.endTimer(timer)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        Spacer()
                    }
                    .frame(height: 45)
                }
                .frame(height: 50)
                
                VStack (spacing: 10) {
                    HStack {
                        Button {
                            self.presentHybridDemo.toggle()
                        } label: {
                            Text("Hybrid Demo")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .fullScreenCover(isPresented: $presentHybridDemo) {
                            NavigationView {
                                BttWebView(tagUrl: tagUrl)
                                    .navigationTitle("Hybrid Demo")
                                    .navigationBarItems(
                                        leading:
                                            Button {
                                                HybridViewModel.showDocInfo()
                                            }
                                        label: {
                                            Image(systemName: "questionmark")
                                                .foregroundColor(.blue)
                                        },
                                        trailing:
                                            Button{
                                                self.presentHybridDemo = false
                                            } label: {
                                                Image(systemName: "xmark")
                                                .foregroundColor(.blue)
                                            }
                                    )
                            }
                        }
                        
                        Button {
                            self.showingAlert.toggle()
                        } label: {
                            Text(" Change tag url")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .alert("", isPresented: $showingAlert) {
                            TextField("", text: $tagUrl)
                            Button("Cancel", role: .cancel, action: {})
                            Button("OK",  action: {})
                        } message: {
                            Text("")
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .frame(height: 45)
                }
                .frame(height: 50)
                
                VStack(spacing: 10){
                    HStack{
                        Button("Configuration Settings") {
                            self.showModal = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityIdentifier("btn_configuration_settings")
                        
                        Spacer()
                    }
                    .frame(height: 45)
                }
                .frame(height: 50)
                
                Spacer()
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .navigationTitle("Settings")
            .bttTrackScreen("SettingsView")
            .fullScreenCover(isPresented: $showModal, content: {
                ConfigurationView(isConfigurationActive: $showModal, vm: ConfigurationModel())
            })
            .navigationDestination(isPresented: self.$isUnitTestsActive, destination: {
                UnitTestsView()
            })
            .onAppear{
                Thread.sleep(forTimeInterval: 3)
            }
        }
        
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(build))"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(vm: .init())
    }
}
