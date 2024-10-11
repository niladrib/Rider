//
//  ClubsView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import SwiftUI

struct ClubRowView: View {
  private let club: Club
  
  init(club: Club) {
    self.club = club
  }
  
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
  private let authContext: AuthContext
  private let makeApiCallsOnAppear: Bool
  @State private var showProgressView = true
  @State private var showFetchFailed = false
  @Binding private var path: [Int]
  
  init(authContext: AuthContext, path: Binding<[Int]>) {
    self.authContext = authContext
    self._path = path
    self.makeApiCallsOnAppear = true
  }
  
  /**
   For previews only
   */
  fileprivate init(authContext: AuthContext, path: Binding<[Int]>,
                   showProgressViewInitialValue: Bool,
                   showFetchFailedInitialValue: Bool,
                   makeApiCallsOnAppear: Bool) {
    self.authContext = authContext
    _showProgressView = State(initialValue: showProgressViewInitialValue)
    _showFetchFailed = State(initialValue: showFetchFailedInitialValue)
    self._path = path
    self.makeApiCallsOnAppear = makeApiCallsOnAppear
  }
  
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
      if makeApiCallsOnAppear {
        Task {
          await fetchClubs()
        }
      } else {
          print("skipping fetch")
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
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  return ClubsView(authContext: authCtx, path: $path,
                   showProgressViewInitialValue: true,
                   showFetchFailedInitialValue: false,
                   makeApiCallsOnAppear: false)
}
