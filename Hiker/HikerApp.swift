//
//  HikerApp.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import SwiftUI

@main
struct HikerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in
//          print("Outh callback URL: \(url)")
        }
    }
//    .modelContainer(for: AuthContext.self)
  }
}
