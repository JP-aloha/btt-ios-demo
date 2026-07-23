//
//  CPUTestView.swift
//
//  Created by Ashok Singh on 01/09/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct CPUTestView: View {
    
    @ObservedObject var viewModel: UnitTestsViewModel
    
    var body: some View {
        VStack(spacing: 0){
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationTitle("CPU Test")
        .bttTrack("\(Self.self)")
        
    }
}

struct CPUTestView_Previews: PreviewProvider {
    static var previews: some View {
        CPUTestView(viewModel: UnitTestsViewModel())
    }
}
