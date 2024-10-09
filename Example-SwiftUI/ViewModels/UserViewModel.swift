//
//  UserViewModel.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import Combine
import Foundation

class UserViewModel : ObservableObject {
    
    private let userKey = "SAVED_USER_DATA"
    @Published var isLoggedIn = false
    
    public init(){
        self.updateLoggedIn()
    }
    
    func loggedInUser() -> User?{
        guard let user = getData() else {
            return nil
        }
        return user
    }
    
    func loggedIn(_ name : String, pass : String, isPremium : Int){
        let user = User(name: name, pass: pass, isPremium: isPremium)
        self.saveData(user)
        self.updateLoggedIn()
    }
    
    func logOut(){
        self.saveData(nil)
        self.updateLoggedIn()
    }
    
    func refresh(){
        self.updateLoggedIn()
    }
    
    private func updateLoggedIn(){
        if let _ = loggedInUser(){
            isLoggedIn = true
        }else{
            isLoggedIn = false
        }
    }
    
    private func saveData(_ user : User?){
        if let user = user, let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }else{
            UserDefaults.standard.removeObject(forKey: userKey)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    private func getData() -> User?{
        if let savedUser = UserDefaults.standard.object(forKey: userKey) as? Data {
            if let user = try? JSONDecoder().decode(User.self, from: savedUser) {
                return user
            }
        }
        return nil
    }
}
