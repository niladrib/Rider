//
//  Club.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import Foundation

struct Club: Identifiable {
  private(set) var id: Int
  private(set) var name: String
  private(set) var profile_medium: URL
  private(set) var profile: URL
  private(set) var member_count: Int
  private(set) var city: String
  private(set) var state: String
  private(set) var localized_sport_type: String
  
  private init(id: Int, name: String, profile_medium: URL, profile: URL,
               member_count: Int, city: String, state: String, localized_sport_type: String) {
    self.id = id
    self.name = name
    self.profile_medium = profile_medium
    self.profile = profile
    self.member_count = member_count
    self.city = city
    self.state = state
    self.localized_sport_type = localized_sport_type
  }
  
  init?(response: ClubResponse) {
    guard let profile_medium = URL(string: response.profile_medium),
          let profile = URL(string: response.profile) else {
      return nil
    }
    self.init(id: response.id, name: response.name
              , profile_medium: profile_medium, profile: profile,
              member_count: response.member_count, city: response.city ?? "N.A.",
              state: response.state ?? "N.A.", localized_sport_type: response.localized_sport_type)
  }
  
  static func createTestClubs() -> [Club] {
    return [Club(id: 1234, name: "Fun Club",
                 profile_medium: URL(string: "https://imgs.search.brave.com/4rX2hgwg-hJz3lKuo5dPya1VB1GAz1-r77zY3F-As0I/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAwLzc0LzE1Lzk1/LzM2MF9GXzc0MTU5/NTU2XzY3bjU4MjNW/N0VpODdhNGc2Skpu/WUhDMHlNU28xQUV5/LmpwZw")!,
                 profile: URL(string: "https://imgs.search.brave.com/4rX2hgwg-hJz3lKuo5dPya1VB1GAz1-r77zY3F-As0I/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAwLzc0LzE1Lzk1/LzM2MF9GXzc0MTU5/NTU2XzY3bjU4MjNW/N0VpODdhNGc2Skpu/WUhDMHlNU28xQUV5/LmpwZw")!,
                 member_count: 20, city: "Nevada City", state: "CA", localized_sport_type: "Running"),
            Club(id: 5678, name: "Sad Club",
                 profile_medium: URL(string: "https://imgs.search.brave.com/xRzvZPCGvqWHY_6Pnm_C1u2QqAEFlPJKC9TAoGsGXT0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTg1/MzA0Mjc0L3Bob3Rv/L2tpdHRlbi5qcGc_/cz02MTJ4NjEyJnc9/MCZrPTIwJmM9WFpZ/NVVsUEdrTEhCSGst/cFlUMGQzNm81NGdO/VW0tWW5RcWYtLTNi/MkU5QT0")!,
                 profile: URL(string: "https://imgs.search.brave.com/xRzvZPCGvqWHY_6Pnm_C1u2QqAEFlPJKC9TAoGsGXT0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTg1/MzA0Mjc0L3Bob3Rv/L2tpdHRlbi5qcGc_/cz02MTJ4NjEyJnc9/MCZrPTIwJmM9WFpZ/NVVsUEdrTEhCSGst/cFlUMGQzNm81NGdO/VW0tWW5RcWYtLTNi/MkU5QT0")!,
                 member_count: 30, city: "Grass Valley", state: "CA", localized_sport_type: "Cycling")]
  }
}
