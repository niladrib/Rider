//
//  KudosView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import SwiftUI

struct KudosView: View {
  @Bindable var authContext: AuthContext
  @Binding private(set) var path: [Int]
  @State private(set) var showProgressView = true
  private(set) var fetchClubsOnAppear = true //for preview only
  
  var kudoMap: [ActivityResponse:[Kudo]] {
    return authContext.loggedInUser?.kudos ?? [:]
  }
  
  var body: some View {
    ZStack {
      List {
        ForEach(Array(kudoMap.keys), id:\.id) {activity in
          Section(activity.name){
            ForEach(kudoMap[activity] ?? []) {kudo in
              Text("\(kudo.firstname) \(kudo.lastname)")
            }
          }
        }
      }
      .padding([.top], 10)
      if showProgressView {
        ProgressView()
      }
    }
    .navigationTitle("Kudos")
    .onAppear {
      Task {
        defer {
          showProgressView = false
        }
        showProgressView = true
        do {
          try await authContext.loggedInUser?.fetchKudos()
        }
        catch RiderError.authError(_) {
          print("Got 401 when fetching clubs; logging out user")
          authContext.loggedInUser = nil
          authContext.isLoggedIn = false
          path = []
        }
        catch {
          print("fetchKudos failed")
        }
      }
    }
    .onDisappear() {
      Task {
        authContext.loggedInUser?.cancelFetchKudos()
      }
    }
  }
}

#Preview {
  let user = User.createTestUser()
  user.clubs = Club.createTestClubs()
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  return  KudosView(authContext: authCtx, path: $path, fetchClubsOnAppear: false)
  
}
