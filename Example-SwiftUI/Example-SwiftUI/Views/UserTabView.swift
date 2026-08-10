//
//  UserTabView.swift
//
//  Root view for the User tab — a table of three rows (Profile, Order
//  History, Favourite), each pushing to its own screen.
//

import SwiftUI
import BlueTriangle

struct UserTabView: View {
    var body: some View {
        List {
            NavigationLink {
                ProfileView()
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
            }

            NavigationLink {
                OrderHistoryView()
            } label: {
                Label("Order History", systemImage: "bag")
            }

            NavigationLink {
                FavouriteView()
            } label: {
                Label("Favourite", systemImage: "heart")
            }
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        UserTabView()
    }
}
