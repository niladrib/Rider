//
//  GenericRetriableErrorView.swift
//  Rider
//
//  Created by Niladri Bora on 9/30/24.
//

import SwiftUI

struct GenericRetriableErrorView: View {
  var retryHandler: () -> Void
  var body: some View {
    HStack {
      Text("A temporary error has ocurred")
      Button("Retry", role: .destructive) { retryHandler() }
          .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  GenericRetriableErrorView(retryHandler: {})
}
