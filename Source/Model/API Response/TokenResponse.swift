//
//  TokenAPIResponse.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import Foundation

struct TokenResponse: Codable {
  /**
   {
     "token_type": "Bearer",
     "expires_at": 1568775134,
     "expires_in": 21600,
     "refresh_token": "e5n567567...",
     "access_token": "a4b945687g...",
     "athlete": {
       #{summary athlete representation}
     }
   }
   */
  let token_type: String
  let expires_at: Int
  let refresh_token: String
  let access_token: String
  let athlete: AthleteResponse
}
