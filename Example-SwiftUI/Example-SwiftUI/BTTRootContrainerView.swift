//
//  BTTRootContrainerView.swift
//
//  Created by Ashok Singh on 27/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import SwiftUI

struct BTTRootContrainerView: View {
    
    @ObservedObject var coordinatorVm: AppCoordinator
    @ObservedObject var vm: BTTConfigModel
    
    var body: some View {
        VStack{
            if !coordinatorVm.isShownTutorial{
                TutorialView(vm: coordinatorVm)
            }else{
                TabContainerView(
                    imageLoader: .live,
                    service: .captured, vm: vm)
            }
        }
    }
}

struct BTTRootContrainerView_Previews: PreviewProvider {
    static var previews: some View {
        BTTRootContrainerView(coordinatorVm: AppCoordinator(), vm: BTTConfigModel())
    }
}
