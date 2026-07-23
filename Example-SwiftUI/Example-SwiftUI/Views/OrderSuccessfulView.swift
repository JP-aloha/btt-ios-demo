//
//  OrderSuccessfulView.swift
//
//  Created by admin on 30/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle
struct OrderSuccessfulView: View {
    var checkoutId: String!
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Thanks for ordering")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 22, weight: .bold))
                Text("Chekout Id: ")
                Text(checkoutId)
                Button(
                    action: {
                        ANRTest.heavyLoop()
                        presentationMode.wrappedValue.dismiss()
                    },
                    label: {
                        Text("Continue Shopping")
                    })
                .bttTrackAction("Continue Shopping_action")
                .accessibilityIdentifier("continue shopping")
                .buttonStyle(.primary())
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                       ToolbarItem(placement: .navigationBarLeading) {
                           Button(action: {
                               presentationMode.wrappedValue.dismiss()
                           }) {
                               HStack {
                                   Image(systemName: "chevron.left")
                                   Text("Cart")
                               }
                           }
                           .accessibilityIdentifier("back")
                       }
                   }
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .navigationTitle("Checkout")
//.bttTrackScreen("OrderSuccessfulView")
        }
        .bttTrack("\(Self.self)")
    }
}

struct OrderSuccessfulView_Previews: PreviewProvider {
    static var previews: some View {
        OrderSuccessfulView(checkoutId: "")
    }
}
