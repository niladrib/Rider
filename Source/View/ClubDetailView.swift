//
//  ClubDetailView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/28/24.
//

import SwiftUI

struct ClubDetailView: View {
  private let club: Club
  
  init(club: Club) {
    self.club = club
  }
  
  var body: some View {
      VStack(alignment: .leading, spacing: 20) {
        Text(club.name)
          .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        AsyncImage(url: club.profile_medium) { phase in
          if let image = phase.image {
            image
              .resizable()
              .scaledToFit()
          } else if phase.error != nil {
            Image(systemName: "exclamationmark.triangle")
          } else {
            ProgressView()
          }
        }
        .frame(maxWidth: .infinity)
        Text("Sport: \(club.localized_sport_type)")
          .font(.title2)
        Text("Member count: \(club.member_count.formatted())")
          .font(.subheadline)
        Text("Location: \(club.city), \(club.state)")
          .font(.subheadline)
        Spacer()
      }
      .navigationTitle("Club Info")
      .navigationBarTitleDisplayMode(.inline)
      .padding([.horizontal], 20)
  }
}

#Preview {
  NavigationStack {
    ClubDetailView(club: Club.createTestClubs().first!)
  }
}
