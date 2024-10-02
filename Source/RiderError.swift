//
//  HikerError.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import Foundation

enum RiderError: Error{
  case apiError(msg: String),
       authError(msg: String),
       unexpectedError(msg: String)
}
