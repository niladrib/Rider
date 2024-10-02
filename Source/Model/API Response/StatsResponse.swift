//
//  StatsResponse.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import Foundation

struct Stat: Codable {
  let count: Int
  let distance: Double
  let moving_time: Int
  let elapsed_time: Int
  let elevation_gain: Double
  let achievement_count: Int?
  
  static func emptyStat() -> Stat {
    return Stat(count: 0, distance: 0, moving_time: 0, elapsed_time: 0, elevation_gain: 0, achievement_count: 0)
  }
}

struct StatsResponse: Codable {
  /**
   {
     "biggest_ride_distance": 0,
     "biggest_climb_elevation_gain": 0,
     "recent_ride_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "recent_run_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "recent_swim_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "ytd_ride_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "ytd_run_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "ytd_swim_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "all_ride_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "all_run_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     },
     "all_swim_totals": {
       "count": 0,
       "distance": 0,
       "moving_time": 0,
       "elapsed_time": 0,
       "elevation_gain": 0,
       "achievement_count": 0
     }
   }
   */
  let recent_ride_totals: Stat
  let all_ride_totals: Stat
  let ytd_ride_totals: Stat
}
