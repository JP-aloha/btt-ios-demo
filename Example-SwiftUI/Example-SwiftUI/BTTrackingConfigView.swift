//
//  BTTrackingConfigView.swift
//
//  Created by Ashok Singh on 27/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct BTTrackingConfigView: View {
    
    @ObservedObject var vm: BTTConfigModel
    
    var body: some View {
        VStack{
            
            Spacer()
            
            HStack{
                Spacer()
                Text("BTT Configuration")
                    .font(Font.system(size: 20, weight: .bold))
                Spacer()
            }
            
            Spacer()
                .frame(height: 60)
            
            VStack {
                HStack{
                    Toggle("ANR Detection", isOn: $vm.anrEnable)
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                HStack{
                    Toggle("Screen Tracking", isOn: $vm.screenTrackingEnable)
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                
                HStack{
                    Toggle("ANR Stack Trace", isOn: $vm.anrStackTrace)
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
            }
            Spacer()
                .frame(height: 20)
            
            HStack{
                Text("Enter Site Id :")
                    .padding(.leading, 15)
                Spacer()
            }
            
            VStack {
                HStack{
                    TextField("Please enter SiteId", text: $vm.txtSiteId)
                        .frame(height: 40)
                        .foregroundColor(.black)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .padding(.leading, 0)
                        .padding(.trailing, 0)
                        .shadow(radius: 2)
                )
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }.frame(height: 40)
            
            VStack{
                
                Spacer()
                    .frame(height: 20)
                
                VStack{
                    HStack{
                        Text("Enter Session Id :")
                            .padding(.leading, 15)
                        Spacer()
                    }
                    
                    HStack{
                        Text("It is in formate ddMMyyhhmm (Current Date).")
                            .font(Font.system(size: 12))
                            .italic()
                            .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        Text("If text field is empty sesionId will be auto generated.")
                            .font(Font.system(size: 12))
                            .italic()
                            .padding(.leading, 15)
                        Spacer()
                    }
                }
                
                VStack {
                    HStack{
                        TextField("Please enter SessionId", text: $vm.txtSessionId)
                            .frame(height: 40)
                            .foregroundColor(.black)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundColor(.white)
                            .padding(.leading, 0)
                            .padding(.trailing, 0)
                            .shadow(radius: 2)
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }.frame(height: 40)
            }
            
            Button(
                action: {
                    if !vm.txtSiteId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        vm.configure()
                    }
                    
                },
                label: {
                    Text("SAVE")
                })
            .buttonStyle(.primary())
            .padding()
            Spacer()
        }
        .onAppear{
            vm.updateSessionId()
        }
        .bttTrack("\(Self.self)")
    }
}

struct BTTrackingConfigView_Previews: PreviewProvider {
    static var previews: some View {
        BTTrackingConfigView(vm: BTTConfigModel())
    }
}
