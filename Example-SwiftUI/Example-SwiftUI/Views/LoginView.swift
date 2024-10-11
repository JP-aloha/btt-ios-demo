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
    
    @State private var selectedSegment : Int = 0
    @State private var username = ""
    @State private var password = ""
	@State private var isLoggedIn = false
    let segments = ["Normal", "Premium"]
	let userModel = UserViewModel()

    var body: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			VStack{
				HStack{
					Button("Cancel") {
						showLoginSheet = false
					}
					.foregroundColor(.white)
					.padding()
					Spacer()
				}
				Spacer()
				VStack(spacing: 20) {
					
					if (!isLoggedIn) {
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
							.disabled(isLoggedIn)
						
						SecureField("Password", text: $password)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.disabled(isLoggedIn)
					} else {
						Text(username)
							.font(.largeTitle)
							.padding(.bottom, 10)
						
						Text(segments[selectedSegment])
							.font(Font.system(size: 16, weight: .regular))//							.padding()
						
					}
					
					HStack {
						if (isLoggedIn) {
							Button("Logout") {
								userModel.logOut()
								BlueTriangle._setMetrics(nil, forKey: "user")
								BlueTriangle._setMetrics(false, forKey: "isPremium")
								username = ""
								password = ""
								isLoggedIn = false
							}
							.padding()
						} else {
							Button("Login"){
								if (!username.isEmpty && !password.isEmpty) {
									let isPremioum = selectedSegment
									userModel.loggedIn(username, pass: password, isPremium: selectedSegment)
									BlueTriangle._setMetrics(username, forKey: "user")
									BlueTriangle._setMetrics((selectedSegment != 0) ? true : false, forKey: "isPremium")
									isLoggedIn = true
								}
							}
							.padding()
						}
					}
				}
				.frame(width: 300)
				.padding()
				.background(Color.white)
				Spacer()
			}
			}
		   .onAppear {
			   if let user = userModel.loggedInUser() {
				   username = user.name
				   password = user.pass
				   selectedSegment = user.isPremium
				   isLoggedIn = true
               }else{
                   isLoggedIn = false
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
