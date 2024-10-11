//
//  ContentView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import SwiftUI
//import SwiftData
import AuthenticationServices

struct ContentView: View {
  private let authController = OAuthController()
  @EnvironmentObject private var locationModel:LocationModel
  @EnvironmentObject private var authContext: AuthContext
  @State private var isLoginInProgress = false
  
  var loggedOutView: some View {
    HStack(spacing: 5) {
      if isLoginInProgress {
        ProgressView()
      }
      Button("Login") {
        isLoginInProgress = true
        Task {
          print("unauthenticated")
          defer {
            isLoginInProgress = false
          }
          let webOAuthUrl = URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=136139&redirect_uri=bora.niladri.Hiker%3A%2F%2Fdevelopers.strava.com&response_type=code&approval_prompt=auto&scope=activity%3Aread%2Cread&state=test")!
          
          do {
            let url = try await authController.webAuth(url: webOAuthUrl, callbackURLScheme: "bora.niladri.Hiker", prefersEphemeralWebBrowserSession: true)
            //          print("callback url=\(url)")
            let components = URLComponents(string: url.absoluteString)
            guard let code = components?.queryItems?.filter({ $0.name=="code"}).first?.value else {
              return
            }
            let result = await User.fetchUser(withCode: code)
            switch result{
            case let .success(user):
              self.authContext.isLoggedIn = true
              self.authContext.loggedInUser = user
              
            case let.failure(error):
              print("error=\(error)")
            }
          }catch {
            print("Got Auth Error=\(error)")
          }
          
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(isLoginInProgress)
    }
  }
  
  var loggedInView: some View {
    VStack {
      LandingPageView()
    }
  }
  
  var body: some View {
    VStack {
      if authContext.isLoggedIn {
        loggedInView
      } else {
        loggedOutView
      }
    }
    .padding()
    .navigationTitle("Rider")
    .toolbar {
      if authContext.isLoggedIn {
        Button("Logout"){}
      }
    }
  }
}

#Preview {
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: false, loggedInUser: user)
  return ContentView()
    .environmentObject(authCtx)
    .environmentObject(LocationModel())
}
