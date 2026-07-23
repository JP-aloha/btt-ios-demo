//
//  MemoryTestView.swift
//
//  Created by Ashok Singh on 01/09/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct MemoryTestView: View {
    
    @ObservedObject var viewModel: UnitTestsViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
                Spacer()
                VStack(spacing: 50){
                    
                    Text("\(viewModel.increasedMemoryInMb) MB memory manually increased")
                    
                    Button("Initial Timer") {
                        viewModel.initalTimer()
                    }
                    
                    Button("Tap To Increase 100 MB memory") {
                        viewModel.runMemoryTestsToIncrease100Mb()
                    }
                    
                    Button("Final Timer") {
                        viewModel.finalTimer()
                    }
                }
                Spacer()
            }
            .navigationTitle("Memory Test")
        }
        .bttTrack("\(Self.self)")
    }
}

struct MemoryTestView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryTestView(viewModel: UnitTestsViewModel())
    }
}
