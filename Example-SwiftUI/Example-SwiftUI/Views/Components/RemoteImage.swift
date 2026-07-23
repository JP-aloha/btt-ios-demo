//
//  RemoteImage.swift
//
//  Created by Mathew Gacy on 11/28/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct RemoteImage: View {
    @State var imageResult: Result<UIImage, Error>?
    let contentMode: ContentMode = .fit
    let imageStatus: ImageStatus

    var body: some View {
        Group {
            if let result = imageResult {
                switch result {
                case .success(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .task {
            await load(imageStatus)
        }
        .bttTrack("\(Self.self)")}

    func load(_ status: ImageStatus) async {
        switch status {
        case .loading(let task):
            imageResult = await task.value.result

        case .downloaded(let result):
            imageResult = result
        }
    }
}
