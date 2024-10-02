//
//  Kudo.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import Foundation

struct Kudo: Codable, Identifiable {
  enum CodingKeys: String, CodingKey {
    case firstname, lastname
  }
  let id = UUID()
  let firstname: String
  let lastname: String
}
