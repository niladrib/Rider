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
  @State private(set) var showFetchFailed = false
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
      if showFetchFailed {
        GenericRetriableErrorView {
          startFetchTask()
        }
        .font(.title2)
      }
    }
    .navigationTitle("Kudos")
    .onAppear {
      startFetchTask()
    }
    .onDisappear() {
      Task {
        authContext.loggedInUser?.cancelFetchKudos()
      }
    }
  }
  
  func startFetchTask() {
    Task {
      defer{
        showProgressView = false
      }
      showFetchFailed = false
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
        showFetchFailed = true
        print("fetchKudos failed")
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
