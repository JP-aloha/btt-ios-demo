//
//  ProfileView.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct ProfileView: View {
    @State private var selectedSegment: Int = 0
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    private let segments = ["Normal", "Premium"]
    private let userModel = UserViewModel()

    var body: some View {
        Form {
            if !isLoggedIn {
                Section("Login") {
                    Picker("Account Type", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Username", text: $username)
                        .accessibilityIdentifier("fld_user_name")

                    SecureField("Password", text: $password)
                        .accessibilityIdentifier("fld_password")

                    Button("Login") {
                        if !username.isEmpty && !password.isEmpty {
                            userModel.loggedIn(username, pass: password, isPremium: selectedSegment)
                            BlueTriangle.setCustomVariable("CV1", value: username)
                            BlueTriangle.setCustomVariable("CV2", value: (selectedSegment != 0) ? true : false)
                            isLoggedIn = true
                        }
                    }
                    .accessibilityIdentifier("btn_login")
                    .bttTrackAction("Login_Button")
                }
            } else {
                Section("Account") {
                    LabeledContent("Username", value: username)
                    LabeledContent("Plan", value: segments[selectedSegment])
                }
                Section {
                    Button("Logout", role: .destructive) {
                        userModel.logOut()
                        BlueTriangle.clearCustomVariable("CV1")
                        BlueTriangle.clearCustomVariable("CV2")
                        username = ""
                        password = ""
                        isLoggedIn = false
                    }
                }
            }
        }
        .onAppear {
            if let user = userModel.loggedInUser() {
                username = user.name
                password = user.pass
                selectedSegment = user.isPremium
                isLoggedIn = true
                BlueTriangle.setCustomVariable("CV1", value: username)
                BlueTriangle.setCustomVariable("CV2", value: (selectedSegment != 0) ? true : false)
                BlueTriangle.setCustomCategory1(user.isPremium != 0 ? "Premium" : "Standard")
            } else {
                BlueTriangle.clearCustomVariable("CV1")
                BlueTriangle.clearCustomVariable("CV2")
                BlueTriangle.setCustomCategory1("Standard")
            }
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    ProfileView()
}
