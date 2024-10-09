//
//  KudosView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import SwiftUI

struct KudosView: View {
  private var authContext: AuthContext
  @Binding private var path: [Int]
  @State private var showProgressView = true
  @State private var showFetchFailed = false
  private var fetchClubsOnAppear = true //for preview only
  
  init(authContext: AuthContext, path: Binding<[Int]>, showProgressView: Bool = true, showFetchFailed: Bool = false, fetchClubsOnAppear: Bool = true) {
    self.authContext = authContext
    self._path = path
    self.showProgressView = showProgressView
    self.showFetchFailed = showFetchFailed
    self.fetchClubsOnAppear = fetchClubsOnAppear
  }
  
  private var kudoMap: [ActivityResponse:[Kudo]] {
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
  
  private func startFetchTask() {
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
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  return  KudosView(authContext: authCtx, path: $path, fetchClubsOnAppear: false)
  
}
