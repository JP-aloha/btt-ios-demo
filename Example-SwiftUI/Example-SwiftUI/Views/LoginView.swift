//
//  LoginView.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct LoginView: View {
    @Binding var showLoginSheet: Bool
    
    @State private var selectedSegment = 0
    @State private var username = ""
    @State private var password = ""
	@State private var isLoggedIn = false
    let segments = ["Normal", "Premium"]
	let userModel = UserViewModel()

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
                       
					   Button(action: {
						   if (isLoggedIn) {
							   userModel.logOut()
							   BlueTriangle.metrics = ["CV1" : "nil"]
						   } else {
							   userModel.loggedIn(username, pass: password, isPremium: selectedSegment)
							   BlueTriangle.metrics = ["CV1" : "Light"]
						   }
						   showLoginSheet = false
					   }) {
						   Text(isLoggedIn ? "Logout" : "Login")
					   }
                       .padding()
                   }
               }
               .frame(width: 300)
               .padding()
               .background(Color.white)
           }
		   .onAppear {
			   if let user = userModel.loggedInUser() {
				   username = user.name
				   password = user.pass
				   selectedSegment = user.isPremium
				   isLoggedIn = true
			   }
		   }
       }
}

/*
#Preview {
    LoginView(showLoginSheet:  .constant(false), 
              userModel: UserViewModel())
}
*/
