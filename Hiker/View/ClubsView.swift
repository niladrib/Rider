//
//  ClubsView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import SwiftUI

struct ClubRowView: View {
  let club: Club
  var body: some View {
    HStack {
      AsyncImage(url: club.profile_medium) { phase in
        if let image = phase.image {
          image
            .resizable()
            .scaledToFit()
        } else if phase.error != nil {
          Image(systemName: "exclamationmark.triangle")
        } else {
          ProgressView()
        }
      }
      .frame(width: 50, height: 50)
      VStack {
        Text(club.name)
          .font(.headline)
        Text("\(club.city), \(club.state)")
          .font(.caption)
      }
    }
  }
}

struct ClubsView: View {
  @Bindable var authContext: AuthContext
  private(set) var fetchClubsOnAppear = true //for preview only
  @State private(set) var showProgressView = true
  @State private(set) var showFetchFailed = false
  @Binding private(set) var path: [Int]
  
  var body: some View {
    ZStack {
      List {
        ForEach(authContext.loggedInUser?.clubs ?? []) {club in
          NavigationLink(value: club.id) {
            ClubRowView(club: club)
          }
        }
      }
      .navigationDestination(for: Int.self) { id in
        if let club = authContext.loggedInUser?.clubs?.filter({$0.id == id}).first {
          ClubDetailView(club: club)
        }
      }
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
    .navigationTitle("Clubs")
    .onAppear {
      startFetchTask()
    }
    .onDisappear{
      self.authContext.loggedInUser?.cancelClubPagesFetch()
    }
  }
  
  private func startFetchTask(){
    Task {
//        print("showProgressView=\(showProgressView)")
      if fetchClubsOnAppear {
        Task {
          await fetchClubs()
        }
      } else {
//          print("skipping fetch")
      }
    }
  }
  
  private func fetchClubs() async {
    defer {
      showProgressView = false
    }
    self.authContext.loggedInUser?.cancelClubPagesFetch()
    showProgressView = true
    showFetchFailed = false
    do {
      _ = try await self.authContext.loggedInUser?.fetchClubs()
    } catch RiderError.authError(_) {
      print("Got 401 when fetching clubs; logging out user")
      authContext.loggedInUser = nil
      authContext.isLoggedIn = false
      path = []
    }
    catch {
      showFetchFailed = true
    }
  }
  
}

#Preview {
  let user = User.createTestUser()
  user.clubs = Club.createTestClubs()
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  let cv = ClubsView(authContext: authCtx, fetchClubsOnAppear: false,
                     showProgressView: false, showFetchFailed: true, path: $path)
  return cv
}
