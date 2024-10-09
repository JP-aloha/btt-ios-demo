//
//  LoginView.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @Binding var showLoginSheet: Bool
    @ObservedObject var userModel : UserViewModel

    @State private var selectedSegment = 0
    @State private var username = ""
    @State private var password = ""
    let segments = ["Normal", "Premium"]

    var body: some View {
           ZStack {
               Color.blue
                   .edgesIgnoringSafeArea(.all)
               VStack(spacing: 20) {
                   Text("Login")
                       .font(.largeTitle)
                   
                   Picker("", selection: $selectedSegment) {
                       ForEach(0..<segments.count) { index in
                           Text(segments[index]).tag(index)
                       }
                   }
                   .pickerStyle(SegmentedPickerStyle())

                   TextField("Username", text: $username)
                       .textFieldStyle(RoundedBorderTextFieldStyle())

                   SecureField("Password", text: $password)
                       .textFieldStyle(RoundedBorderTextFieldStyle())

                   HStack {
                       Button("Cancel") {
                           showLoginSheet = false
                       }
                       .padding()
                       
                       Button("Login") {
                           userModel.loggedIn(username, pass: password, isPremium: 1)
                           showLoginSheet = false
                       }
                       .padding()
                   }
               }
               .frame(width: 300)
               .padding()
               .background(Color.white)
           }
       }
}

#Preview {
    LoginView(showLoginSheet:  .constant(false), 
              userModel: UserViewModel())
}
