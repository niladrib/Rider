//
//  AuthContext.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import Foundation

@Observable
class AuthContext {
  var isLoggedIn: Bool 
  var loggedInUser: User?
  
  init(isLoggedIn: Bool, loggedInUser: User? = nil) {
    self.isLoggedIn = isLoggedIn
    self.loggedInUser = loggedInUser
  }
}
