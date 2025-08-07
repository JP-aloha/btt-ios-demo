//
//  TutorialPageView.swift
//
//  Created by Ashok Singh on 07/08/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import SwiftUI

struct TutorialPageView: View {
    let model: TutorialPageModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Spacer()
                Text(model.title)
                    .fontWeight(.bold)
                Spacer()
            }
            Text(model.desc)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
        }
    }
}
