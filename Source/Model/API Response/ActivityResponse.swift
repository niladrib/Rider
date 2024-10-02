//
//  ActivityResponse.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import Foundation

struct ActivityResponse: Codable, Identifiable, Hashable {
  let name: String
  let id: Int
  let type: String
  let kudos_count: Int
}
