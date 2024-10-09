//
//  StatsView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import SwiftUI

struct ProfileView: View {
  private var authContext: AuthContext
  @Binding private var path: [Int]
  @State private var showProgressView = false
  @State private var showFetchFailed = false
  
  init(authContext: AuthContext, path: Binding<[Int]>, showProgressView: Bool = false, showFetchFailed: Bool = false, fetchStatsOnAppear: Bool = true) {
    self.authContext = authContext
    self._path = path
    self.showProgressView = showProgressView
    self.showFetchFailed = showFetchFailed
    self.fetchStatsOnAppear = fetchStatsOnAppear
  }

  private var showStats: Bool {
    return authContext.loggedInUser?.recentRideTotals != nil &&
    authContext.loggedInUser?.ytdRideTotals != nil &&
    authContext.loggedInUser?.allRideTotals != nil
  }
  
  private var fetchStatsOnAppear = true
  
  var body: some View {
    ZStack {
      List {
        Section {
          Text("Name: \(authContext.loggedInUser?.firstname.capitalized ?? "") \(authContext.loggedInUser?.lastname.capitalized ?? "")")
        }
        if showStats {
          Section("Recent Rides") {
            createStatView(stat: authContext.loggedInUser?.allRideTotals)
          }
          Section("Year-to-date Rides") {
            createStatView(stat: authContext.loggedInUser?.allRideTotals)
          }
          Section("All Rides") {
            createStatView(stat: authContext.loggedInUser?.allRideTotals)
          }
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
    .navigationTitle("Profile")
    .onAppear{
      startFetchTask()
    }
  }
  
  private func startFetchTask() {
    if self.fetchStatsOnAppear {
      Task {
        defer {
          showProgressView = false
        }
        showFetchFailed = false
        showProgressView = true
        do {
          try await authContext.loggedInUser?.fetchRideStats()
        }
        catch RiderError.authError(_) {
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
  }
  
  private func createStatView(stat: Stat?) -> some View {
    let stat = stat ?? Stat.emptyStat()
    return VStack(alignment: .center) {
      Text("Rides: \(stat.count)")
      Text("Distance: \(metersToMiles(stat.distance) ?? "0") miles")
      Text("Time: \(secondsToMinutes(stat.moving_time)) minutes")
      Text("Elevation gain: \(metersToFeet(stat.elevation_gain) ?? "") ft")
      Text("Achievement count: \(stat.achievement_count ?? 0)")
    }
  }
  
  private func metersToMiles(_ meters: Double) -> String? {
    let miles = Measurement(value: meters, unit: UnitLength.meters)
      .converted(to: .miles).value
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    return formatter.string(for: miles)
  }
  
  private func metersToFeet(_ meters: Double) -> String? {
    let miles = Measurement(value: meters, unit: UnitLength.meters)
      .converted(to: .feet).value
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 0
    return formatter.string(for: miles)
  }
  
  private func secondsToMinutes(_ secs: Int) -> Int {
    return secs/60
  }
  
}

#Preview {
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  return NavigationStack {
    ProfileView(authContext: authCtx, path: $path, fetchStatsOnAppear: false)
  }
}
