//
//  ClubsResponse.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import Foundation

struct ClubResponse: Codable {
  /**
   {
       "id": 22789,
       "resource_state": 2,
       "name": "Forest Service Strava Club",
       "profile_medium": "https://dgalywyr863hv.cloudfront.net/pictures/clubs/22789/510773/1/medium.jpg",
       "profile": "https://dgalywyr863hv.cloudfront.net/pictures/clubs/22789/510773/1/large.jpg",
       "cover_photo": null,
       "cover_photo_small": null,
       "activity_types": [
         "Run",
         "VirtualRun",
         "Wheelchair"
       ],
       "activity_types_icon": "sports_run_normal",
       "dimensions": [
         "distance",
         "num_activities",
         "best_activities_distance",
         "elev_gain",
         "moving_time",
         "velocity"
       ],
       "sport_type": "running",
       "localized_sport_type": "Running",
       "city": "Nevada City",
       "state": "California",
       "country": "United States",
       "private": false,
       "member_count": 874,
       "featured": false,
       "verified": false,
       "url": "forest-service-strava-club"
     }
   */
  let id: Int
  let name: String
  let profile_medium: String
  let profile: String
  let member_count: Int
  let city: String?
  let state: String?
  let localized_sport_type: String
}
