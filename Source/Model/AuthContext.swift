//
//  AuthContext.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import Foundation

class AuthContext: ObservableObject {
  @Published var isLoggedIn: Bool
  @Published var loggedInUser: User?
  
  init(isLoggedIn: Bool, loggedInUser: User? = nil) {
    self.isLoggedIn = isLoggedIn
    self.loggedInUser = loggedInUser
  }
}
