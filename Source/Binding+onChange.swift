//
//  Binding+onChange.swift
//  Rider
//
//  Created by Niladri Bora on 9/30/24.
//

import SwiftUI

extension Binding {
  @MainActor
  func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      }
    )
  }
}
