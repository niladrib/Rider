//
//  LandingPageView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import SwiftUI

fileprivate enum Tabs: String {
  case landing, kudos, segments, profile
}

struct LandingPageView: View {
  @State private var selectedTab = Tabs.landing
  private var authContext: AuthContext
  private var location: LocationModel
  @State private var path = [Int]()
  
  init(authContext: AuthContext, location: LocationModel, path: [Int] = [Int]()) {
    self.authContext = authContext
    self.location = location
    self.path = path
  }
  
  var body: some View {
    TabView(selection: $selectedTab.onChange{ _ in path = []}) {
      NavigationStack(path: $path) {
        ClubsView(authContext: authContext, path: $path)
      }
      .tabItem {
        Label("Clubs", systemImage: "person.3.fill")
      }
      .tag(Tabs.landing)
      
      NavigationStack(path: $path) {
        KudosView(authContext: authContext, path: $path)
      }
      .tabItem {
        Label("Kudos", systemImage: "hands.clap.fill")
      }
      .tag(Tabs.kudos)
      
      NavigationStack(path: $path) {
        SegmentsView(locationViewModel: location, authContext: authContext,
        path: $path)
      }
      .tabItem {
        Label("Segments", systemImage: "map.fill")
      }
      .tag(Tabs.segments)
      
      NavigationStack(path: $path) {
        ProfileView(authContext: authContext, path: $path)
      }
      .tabItem {
        Label("Profile", systemImage: "person.fill")
      }
      .tag(Tabs.profile)
      
    }
  }
}

#Preview {
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  return LandingPageView(authContext: authCtx, location: LocationModel())
}
