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
  let authController = OAuthController()
  let location = LocationModel()
  @State var authContext: AuthContext?
  
  var loggedOutView: some View {
    Button("Login") {
      Task {
//        print("unauthenticated")
        let webOAuthUrl = URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=136139&redirect_uri=bora.niladri.Hiker%3A%2F%2Fdevelopers.strava.com&response_type=code&approval_prompt=auto&scope=activity%3Aread%2Cread&state=test")!
        
        do {
          let url = try await authController.webAuth(url: webOAuthUrl, callbackURLScheme: "bora.niladri.Hiker", prefersEphemeralWebBrowserSession: true)
//          print("callback url=\(url)")
          let components = URLComponents(string: url.absoluteString)
          guard let code = components?.queryItems?.filter({ $0.name=="code"}).first?.value else {
            return
          }
          let result = await User.fetchToken(withCode: code)
          switch result{
          case let .success(user):
            self.authContext = AuthContext(isLoggedIn: true, loggedInUser: user)
            
          case let.failure(error):
            print("error=\(error)")
            self.authContext = AuthContext(isLoggedIn: false)
          }
        }catch {
          print("Got Auth Error=\(error)")
        }
        
      }
    }
    .buttonStyle(.borderedProminent)
  }
  
  var loggedInView: some View {
    VStack {
      if let authContext = authContext {
        LandingPageView(authContext: authContext, location: location)
      }
    }
  }
  
  var body: some View {
      VStack {
        if authContext?.isLoggedIn ?? false {
          loggedInView
        } else {
          loggedOutView
        }
      }
      .padding()
      .navigationTitle("Rider")
      .toolbar {
        if authContext?.isLoggedIn ?? false {
          Button("Logout"){}
        }
      }
  }
}
  
#Preview {
  let user = User.createTestUser()
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  return ContentView(authContext: authCtx)
}
