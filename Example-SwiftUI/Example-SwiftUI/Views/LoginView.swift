//
//  LoginView.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//
//  The single login/account form, used both standalone (User tab's Profile
//  row, pushed onto the app's existing NavigationStack) and modally (the
//  toolbar's fullScreenCover, wrapped in its own NavigationStack with a
//  Cancel button) — there's no reason to maintain two near-identical login
//  forms when the only real difference between those two entry points is
//  how the screen is presented, not what's on it.
//

import SwiftUI
import BlueTriangle

struct LoginView: View {
    private enum Field: Hashable {
        case username
        case password
    }

    @Binding var showLoginSheet: Bool
    var showsCancelButton: Bool = true

    @State private var selectedSegment: Int = 0
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @FocusState private var focusedField: Field?
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
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .username)
                        .onSubmit { focusedField = .password }
                        .accessibilityIdentifier("fld_user_name")

                    SecureField("Password", text: $password)
                        .submitLabel(.go)
                        .focused($focusedField, equals: .password)
                        .onSubmit(login)
                        .accessibilityIdentifier("fld_password")

                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity, alignment: .center)
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
                    Button("Logout", role: .destructive, action: logout)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }
        )
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            if showsCancelButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showLoginSheet = false
                    }
                    .accessibilityIdentifier("btn_Cancel")
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

    private func login() {
        guard !username.isEmpty, !password.isEmpty else { return }
        focusedField = nil
        userModel.loggedIn(username, pass: password, isPremium: selectedSegment)
        BlueTriangle.setCustomVariable("CV1", value: username)
        BlueTriangle.setCustomVariable("CV2", value: (selectedSegment != 0) ? true : false)
        isLoggedIn = true
    }

    private func logout() {
        userModel.logOut()
        BlueTriangle.clearCustomVariable("CV1")
        BlueTriangle.clearCustomVariable("CV2")
        username = ""
        password = ""
        isLoggedIn = false
    }
}

#Preview {
    LoginView(showLoginSheet: .constant(false))
}
