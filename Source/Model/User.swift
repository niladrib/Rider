//
//  User.swift
//  Hiker
//
//  Created by Niladri Bora on 9/27/24.
//

import Foundation

fileprivate let MAX_KUDO_COUNT=50

class User: ObservableObject {
  @Published private(set) var accessToken: String
  @Published private(set) var refreshToken: String
  @Published private(set) var expiryDate: Date
  @Published private(set) var id: Int
  @Published private(set) var username: String
  @Published private(set) var firstname: String
  @Published private(set) var lastname: String
  @Published private(set) var clubs: [Club]?
  @Published private(set) var kudos: [ActivityResponse: [Kudo]]?
  @Published private(set) var recentRideTotals: Stat?
  @Published private(set) var allRideTotals: Stat?
  @Published private(set) var ytdRideTotals: Stat?

  private init(resp: TokenResponse) {
    self.accessToken = resp.access_token
    self.refreshToken = resp.refresh_token
    self.expiryDate = 
    Date(timeIntervalSince1970: TimeInterval(resp.expires_at))
    self.id = resp.athlete.id
    self.username = resp.athlete.username
    self.firstname = resp.athlete.firstname
    self.lastname = resp.athlete.lastname
  }
  
  private init(accessToken: String,
               refreshToken: String,
               expiryDate: Date,
               id: Int,
               username: String,
               firstname: String,
               lastname: String,
               recentRideTotals: Stat,
               ytdRideTotals: Stat,
               allRideTotals: Stat) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.expiryDate = expiryDate
    self.id = id
    self.username = username
    self.firstname = firstname
    self.lastname = lastname
    self.recentRideTotals = recentRideTotals
    self.ytdRideTotals = ytdRideTotals
    self.allRideTotals = allRideTotals
  }
  
  public func fetchClubs() async throws -> [Club] {
    if let clubs = self.clubs {
      return clubs
    }
    clubs = [Club]()
//    print("fetching clubs")
    do {
      for try await clubPage in clubPages{
        clubs?.append(contentsOf: clubPage)
      }
      guard let clubs = clubs else {
        assert(false, "clubs shouldn't be nil here")
        throw RiderError.unexpectedError(msg: "clubs is unexpectedly nil in User")
      }
      return clubs
    } catch {
      clubs = nil
      throw error
    }
  }
  
  public func cancelClubPagesFetch() {
    clubPagesFetchTask?.cancel()
    clubPagesFetchTask = nil
  }
  
  private var clubPagesFetchTask: Task<Void, Error>?
  
  private var clubPages: AsyncThrowingStream<[Club], Error> {
    AsyncThrowingStream<[Club], Error> {continuation in
      clubPagesFetchTask = Task {
        defer {
          clubPagesFetchTask = nil
        }
        for pageIdx in 1...Int.max {
          if Task.isCancelled {
            continuation.finish(throwing: RiderError.unexpectedError(msg: "clubs fetch task cancelled"))
            return
          }
//          print("fetching page=\(pageIdx)")
          let query = [URLQueryItem(name: "page", value: String(pageIdx)),
                       URLQueryItem(name: "per_page", value: "30")]
          guard var urlComponents = URLComponents(string: "https://www.strava.com/api/v3/athlete/clubs") else {
            fatalError("Malformed clubs url")
          }
          urlComponents.queryItems = query
          guard let url = urlComponents.url else {
            fatalError("Malformed clubs URL")
          }
          var request = URLRequest(url: url)
          request.httpMethod = "GET"
          request.addValue("application/json", forHTTPHeaderField: "accept")
          request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
          do {
            let (data, resp) = try await URLSession.shared.data(for: request)
//            print("response = \(String(describing: String(data: data, encoding: .utf8)))")
            guard let resp = resp as? HTTPURLResponse else {
              fatalError("Unexpected non-http response type")
            }
            switch resp.statusCode {
            case 200..<300:
              let decoder = JSONDecoder()
              let clubResponses = try decoder.decode([ClubResponse].self, from: data)
//              print("clubResponses=\(clubResponses)")
              let clubs = clubResponses.map{Club(response: $0)}.compactMap{$0}
//              print("clubs=\(clubs)")
              if clubs.count > 0 {
                continuation.yield(clubs)
              } else {
                continuation.finish()
                return
              }
              
            case 401:
              continuation.finish(throwing: RiderError.authError(msg: "Got 401 http status code"))
              
            default:
              let msg = """
    Got error response for clubs api;status=\(resp.statusCode); \
    body=\(String(describing: String(data: data, encoding: .utf8)))
    """
              print(msg)
              continuation.finish(throwing: RiderError.apiError(msg: msg))
              return
            }
          } catch {
            let msg = "Clubs fetch failed with error=\(error)"
            print(msg)
            continuation.finish(throwing: error)
            return
          }
        }
      }
    }
  }
                                                  
  static func createTestUser(withClubs clubs: [Club]) -> User {
    let user = User(accessToken: "381737", refreshToken: "adhjhd",
                expiryDate: Date(), id: 37873,
                username: "n_b", firstname: "niladri", lastname: "bora",
                recentRideTotals: Stat(count: 2, distance: 200, moving_time: 4774, elapsed_time: 4774, elevation_gain: 24, achievement_count: 0),
                ytdRideTotals: Stat(count: 3, distance: 210, moving_time: 4784, elapsed_time: 4784, elevation_gain: 28, achievement_count: 1),
                allRideTotals: Stat(count: 4, distance: 300, moving_time: 4874, elapsed_time: 4874, elevation_gain: 34, achievement_count: 2))
    user.clubs = clubs
    return user
  }
  
  static func fetchUser(withCode code: String) async -> Result<User, Error> {
//    print("fetching token")
    let query = [URLQueryItem(name: "client_id", value: "136139"),
                 URLQueryItem(name: "client_secret", value: "d402ce17bb7f40541238430b30b27889d7ea333c"),
                 URLQueryItem(name: "code", value: code),
                 URLQueryItem(name: "grant_type", value: "authorization_code")]
    guard var urlComponents = URLComponents(string: "https://www.strava.com/api/v3/oauth/token") else {
      fatalError("Malformed oauth token  URL")
    }
    urlComponents.queryItems = query
    guard let url = urlComponents.url else {
      fatalError("Malformed oauth token URL")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    do {
      let (data, resp) = try await URLSession.shared.data(for: request)
//      print("response = \(String(describing: String(data: data, encoding: .utf8)))")
      guard let resp = resp as? HTTPURLResponse else {
        let msg = "Unexpected non-http response type"
        assert(true, msg)
        return .failure(RiderError.apiError(msg: msg))
      }
      switch resp.statusCode {
      case 200..<300:
        let decoder = JSONDecoder()
        let token = try decoder.decode(TokenResponse.self, from: data)
        return .success(User(resp: token))
        
      default:
        let msg = """
Got error response for token api;status=\(resp.statusCode); \
body=\(String(describing: String(data: data, encoding: .utf8)))
"""
        print(msg)
        return .failure(RiderError.apiError(msg: msg))
      }
      //TODO: handle http response codes here
    } catch {
      let msg = "Token fetch failed with error=\(error)"
      print(msg)
      return .failure(RiderError.apiError(msg: msg))
    }
  }

  func fetchRideStats() async throws {
    if self.recentRideTotals != nil && self.ytdRideTotals != nil &&
        self.allRideTotals != nil {
      return
    }
//    print("fetchRideStats()")
    guard let url = URL(string: "https://www.strava.com/api/v3/athletes/\(self.id)/stats") else {
      fatalError("malformed stats URL")
    }
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
    do {
      let (data, resp) = try await URLSession.shared.data(for: request)
      guard let resp = resp as? HTTPURLResponse else {
        fatalError("Unexpected non-http response type")
      }
//      print("data=\(String(describing: String(data: data, encoding: .utf8)))")
      switch resp.statusCode {
      case 200..<300:
        let decoder = JSONDecoder()
        let statResp = try decoder.decode(StatsResponse.self, from: data)
//        print("statResponse=\(statResp)")
        self.recentRideTotals = statResp.recent_ride_totals
        self.ytdRideTotals = statResp.ytd_ride_totals
        self.allRideTotals = statResp.all_ride_totals
        
      case 401:
        throw RiderError.authError(msg: "Got 401 http status code")
        
      default:
        let msg = """
Got error response for clubs api;status=\(resp.statusCode); \
body=\(String(describing: String(data: data, encoding: .utf8)))
"""
        print(msg)
        throw RiderError.unexpectedError(msg: msg)
      }
    } catch {
      print("stats error=\(error)")
      self.recentRideTotals = nil
      self.ytdRideTotals = nil
      self.allRideTotals = nil
      throw error
    }
  }
  
  func cancelFetchKudos() {
    self.cancelActivityPagesFetch()
  }
  
  func fetchKudos()  async throws {
    if self.kudos != nil {
      //We have already fetched the data before 
      return
    }
    do {
//      print("fetching kudos from the backend")
      self.kudos = [ActivityResponse: [Kudo]]()
      for try await activityPage in activityPages {
        var actitvitiesToFetch = [ActivityResponse]()
        var kudoCountEstimate = self.kudos?.count ?? 0
        /**
         Make a list of activities for which to fetch the kudos. If we have
         exceeded the `MAX_KUDO_COUNT` we don't need to add anymore activities
         to the list
         */
        for activity in activityPage {
          if kudoCountEstimate <= MAX_KUDO_COUNT {
            //          kudoCountEstimate += activity.kudos_count
            kudoCountEstimate += 1
            actitvitiesToFetch.append(activity)
          } else {
            break
          }
        }
        //Fetch kudos for the selected activties in parallel
        let kudos = try await withThrowingTaskGroup(of: (ActivityResponse, [Kudo]).self) { group  in
          var kudos = [ActivityResponse: [Kudo]]()
          for activity in actitvitiesToFetch {
            group.addTask {
              let activityKudos = try await self.fetchKudos(activityId: activity.id)
              return (activity, activityKudos)
            }
          }
          for try await activityKudos in group {
            //          kudos.append(contentsOf: activityKudos)
            kudos[activityKudos.0] = activityKudos.1
          }
          return kudos
        }
        //      self.kudos?.append(contentsOf: kudos)
        for (key, value) in kudos {
          self.kudos?[key] = value
        }
        if (self.kudos?.count ?? 0) > MAX_KUDO_COUNT {
          break
        }
      }
    } catch {
      print("fetchKudos() failed with error=\(error)")
      self.kudos = nil
      throw error
    }
  }
  
  private func fetchKudos(activityId: Int)async throws -> [Kudo] {
//    print("fetching kudos")
    /**
     We will not paginate this API. We will assume that an aactivity can have a
     max number of 30 kudos per activity
     */
    let query = [URLQueryItem(name: "page", value: "1"),
                 URLQueryItem(name: "per_page", value: "30")]
    guard var urlComponents = URLComponents(string: "https://www.strava.com/api/v3/activities/\(activityId)/kudos") else {
      fatalError("Malformed kudos url")
    }
    urlComponents.queryItems = query
    guard let url = urlComponents.url else {
      fatalError("Malformed kudos URL")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
    do {
      let (data, resp) = try await URLSession.shared.data(for: request)
//      print("response(activity=\(activityId) )= \(String(describing: String(data: data, encoding: .utf8)))")
      guard let resp = resp as? HTTPURLResponse else {
        fatalError("Unexpected non-http response type")
      }
      switch resp.statusCode {
      case 200..<300:
        let decoder = JSONDecoder()
        let kudos = try decoder.decode([Kudo].self, from: data)
        return kudos
      
      case 401:
        throw RiderError.authError(msg: "Got 401 http status code")
        
      default:
        let msg = """
Got error response for activities api;status=\(resp.statusCode); \
body=\(String(describing: String(data: data, encoding: .utf8)))
"""
        print(msg)
        throw RiderError.apiError(msg: msg)
      }
    } catch {
      let msg = "Clubs fetch failed with error=\(error)"
      print(msg)
      throw error
    }
  }
  
  private func cancelActivityPagesFetch() {
    activityPagesFetchTask?.cancel()
    activityPagesFetchTask = nil
  }
  
  private var activityPagesFetchTask: Task<Void, Error>?
  
  private var activityPages: AsyncThrowingStream<[ActivityResponse], Error> {
    AsyncThrowingStream<[ActivityResponse], Error> {continuation in
      activityPagesFetchTask = Task {
        defer {
          activityPagesFetchTask = nil
        }
        for pageIdx in 1...Int.max {
          if Task.isCancelled {
            continuation.finish(throwing: RiderError.unexpectedError(msg: "actitivy fetch task cancelled"))
            return
          }
//          print("fetching activity page=\(pageIdx)")
          let query = [URLQueryItem(name: "page", value: String(pageIdx)),
                       URLQueryItem(name: "per_page", value: "30")]
          guard var urlComponents = URLComponents(string: "https://www.strava.com/api/v3/athlete/activities") else {
            fatalError("Malformed clubs url")
          }
          urlComponents.queryItems = query
          guard let url = urlComponents.url else {
            fatalError("Malformed clubs URL")
          }
          var request = URLRequest(url: url)
          request.httpMethod = "GET"
          request.addValue("application/json", forHTTPHeaderField: "accept")
          request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
          do {
            let (data, resp) = try await URLSession.shared.data(for: request)
//            print("response = \(String(describing: String(data: data, encoding: .utf8)))")
            guard let resp = resp as? HTTPURLResponse else {
              fatalError("Unexpected non-http response type")
            }
            switch resp.statusCode {
            case 200..<300:
              let decoder = JSONDecoder()
              let activityResponses = try decoder.decode([ActivityResponse].self, from: data)
//              print("activityResponses=\(activityResponses)")
              if activityResponses.count > 0 {
                continuation.yield(activityResponses)
              } else {
                continuation.finish()
                return
              }
              
            default:
              let msg = """
    Got error response for activities api;status=\(resp.statusCode); \
    body=\(String(describing: String(data: data, encoding: .utf8)))
    """
              print(msg)
              continuation.finish(throwing: RiderError.apiError(msg: msg))
              return
            }
          } catch {
            let msg = "Clubs fetch failed with error=\(error)"
            print(msg)
            continuation.finish(throwing: error)
            return
          }
        }//end for pageIdx
      }
    }
  }
  
  func getSegmentsFor(southwestCornerLatitutde: Double,
                      southwestCornerLongitude: Double,
                      northeastCornerLatitude: Double,
                      northeastCornerlongitude: Double)
  async throws -> [Segment] {
    let query = [URLQueryItem(name: "bounds",
                              value: """
\(format(latlong: southwestCornerLatitutde)),\(format(latlong: southwestCornerLongitude)),\
\(format(latlong: northeastCornerLatitude)),\(format(latlong: northeastCornerlongitude))
""")]
    guard var urlComponents = URLComponents(string: "https://www.strava.com/api/v3/segments/explore") else {
      fatalError("Malformed segments url")
    }
    urlComponents.queryItems = query
    guard let url = urlComponents.url else {
      fatalError("Malformed segments URL")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
//    print("segements req=\(request)")
    do {
      let (data, resp) = try await URLSession.shared.data(for: request)
//      print("response(segments= \(String(describing: String(data: data, encoding: .utf8)))")
      guard let resp = resp as? HTTPURLResponse else {
        fatalError("Unexpected non-http response type")
      }
      switch resp.statusCode {
      case 200..<300:
        let decoder = JSONDecoder()
        let segments = try decoder.decode(SegmentsResponse.self, from: data)
        return segments.segments
       
      case 401:
        throw RiderError.authError(msg: "Got 401 http status code")
        
      default:
        let msg = """
Got error response for segments api;status=\(resp.statusCode); \
body=\(String(describing: String(data: data, encoding: .utf8)))
"""
        print(msg)
        throw RiderError.apiError(msg: msg)
      }
    } catch {
      let msg = "Segments fetch failed with error=\(error)"
      print(msg)
      throw error
    }
  }
  
  private func format(latlong: Double) -> String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 7
    return formatter.string(for: latlong) ?? "0.0"
  }

}

