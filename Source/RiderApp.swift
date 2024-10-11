//
//  HikerApp.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import SwiftUI

@main
struct RiderApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in
          //          print("Outh callback URL: \(url)")
        }
        .environmentObject(getAuthContext())
        .environmentObject(getLocationModel())
    }
  }
  
  private func getAuthContext() -> AuthContext {
    //TODO: read from encrypted storage to see if user has logged in before
    return AuthContext(isLoggedIn: false)
  }
  
  private func getLocationModel() -> LocationModel {
    return LocationModel()
  }
}

