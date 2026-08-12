//
//  UserTabView.swift
//
//  Root view for the User tab — a table of three rows (Profile, Order
//  History, Favourite), each pushing to its own screen.
//

import SwiftUI
import BlueTriangle

struct UserTabView: View {
    @State private var loggedInName: String?
    private let userModel = UserViewModel()

    private var profileRowTitle: String {
        loggedInName ?? "Guest User"
    }

    var body: some View {
        List {
            NavigationLink {
                LoginView(showLoginSheet: .constant(false), showsCancelButton: false)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Label(profileRowTitle, systemImage: "person.crop.circle.fill")
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
        .onAppear {
            // Re-read on every appearance (including popping back from
            // ProfileView after a login/logout) rather than once at init,
            // since ProfileView owns its own UserViewModel instance and
            // won't otherwise notify this one.
            loggedInName = userModel.loggedInUser()?.name
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        UserTabView()
    }
}
