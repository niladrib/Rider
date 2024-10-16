//
//  SegmentsView.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import SwiftUI
import CoreLocation
import MapKit

/**
 attribution: https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
 */

struct SegmentsView: View {
  @EnvironmentObject private var locationViewModel: LocationModel
  @EnvironmentObject private var authContext: AuthContext
  @Binding private(set) var path: [Int]
  
  var body: some View {
    switch locationViewModel.authorizationStatus {
    case .notDetermined:
      RequestLocationView()
      
    case .restricted:
      LocationErrorView(text: "Location use is restricted.")
      
    case .denied:
      LocationErrorView(text: "The app does not have location permissions. Please enable them in settings.")
      
    case .authorizedAlways, .authorizedWhenInUse:
      LocationTrackingView(path: $path)
      
    default:
      Text("Unexpected status")
    }
  }
}

struct RequestLocationView: View {
  @EnvironmentObject private var locationViewModel: LocationModel
  
  var body: some View {
    VStack {
      Image(systemName: "location.circle")
        .resizable()
        .frame(width: 100, height: 100, alignment: .center)
        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
      Button(action: {
        locationViewModel.requestPermission()
      }, label: {
        Label("Allow tracking", systemImage: "location")
      })
      .padding(10)
      .foregroundColor(.white)
      .background(Color.blue)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      Text("We need your location to find segments near you.")
        .foregroundColor(.gray)
        .font(.caption)
    }
  }
}

struct LocationErrorView: View {
  let text: String
  var body: some View {
    Text(text)
  }
}

struct LocationTrackingView: View {
  @EnvironmentObject private var locationViewModel: LocationModel
  @EnvironmentObject private var authContext: AuthContext
  @Binding var path: [Int]
  @State private var position: MapCameraPosition = .userLocation(
    fallback: .camera(
      MapCamera(centerCoordinate: .sanFrancisco, distance: 10)
    )
  )
  @State private var currentRegion: MKCoordinateRegion?
  @State private var segments = [Segment]()
  @State private var displayedSegment: Segment?
  @State private var showProgressView = false
  @State private var showingNoSegmentsFoundAlert = false
  @State private var showFetchFailed = false
  
  var body: some View {
    VStack {
      Map(position: $position) {
        Marker(coordinate: locationViewModel.lastSeenLocation?.coordinate ?? .sanFrancisco) {
          Label("", systemImage: "location")
        }
        
        if displayedSegment != nil {
          Marker(coordinate: CLLocationCoordinate2D(
            latitude: displayedSegment!.start_latlng[0],
            longitude: displayedSegment!.start_latlng[1])) {
              Label(displayedSegment!.name, systemImage: "mappin")
            }
        }
      }
      .mapStyle(
        .hybrid(
          elevation: .realistic,
          showsTraffic: true
        )
      )
      .mapControls {
        MapScaleView()
        MapCompass()
      }
      .onMapCameraChange(frequency: .onEnd) { context in
//        print("onMapCameraChange \(context.region)")
        currentRegion = context.region
      }
      .frame(maxWidth: .infinity, maxHeight: 300)
      .clipped()
      if showFetchFailed {
        Text("Search failed. Please retry.")
          .foregroundStyle(.red)
      }
      Button(action: {
        startFetchTask()
      }, label: {
        HStack {
          if showProgressView {
            ProgressView()
          }
          Text("Search for Segments")
        }
      })
      .disabled(showProgressView)
      .alert("No Segments Found", isPresented: $showingNoSegmentsFoundAlert) {
          Button("OK", role: .cancel) { 
            showingNoSegmentsFoundAlert = false
          }
      } message: {
          Text("No segements found in the map display area. \nTry widening your search by zooming out.")
      }
      .padding()
      .buttonStyle(.borderedProminent)
      List {
        ForEach(segments){segment in
          Button(segment.name) {
            showOnMap(segment)
          }
        }
      }
      Spacer()
    }//VStack
    .navigationTitle("Segments")
    .onAppear {
      locationViewModel.startUpdatingLocation()
    }
    .onDisappear {
      locationViewModel.stopUpdatingLocation()
    }
  }
  
  private func startFetchTask() {
    guard let center = currentRegion?.center,
          let span = currentRegion?.span else {
      return
    }
    self.segments = []
    Task {
      defer {
        showProgressView = false
      }
      showProgressView = true
      showFetchFailed = false
      do {
        guard let segments = try await authContext
          .loggedInUser?
          .getSegmentsFor(southwestCornerLatitutde: center.latitude - span.latitudeDelta/2,
                          southwestCornerLongitude: center.longitude - span.longitudeDelta/2,
                          northeastCornerLatitude: center.latitude + span.latitudeDelta/2,
                          northeastCornerlongitude: center.longitude + span.longitudeDelta/2) else {
          return
        }
//            print("segments near me=\(String(describing: segments))")
        self.segments = segments
        showingNoSegmentsFoundAlert = (segments.count == 0)
      }
      catch RiderError.authError(_) {
        print("Got 401 when fetching clubs; logging out user")
        authContext.loggedInUser = nil
        authContext.isLoggedIn = false
        path = []
      }
      catch {
        showFetchFailed = true
      }
    }
  }
  
  func showOnMap(_ segment: Segment) {
    guard var region = self.currentRegion else {
      return
    }
    region.center = CLLocationCoordinate2D(latitude: segment.start_latlng[0], longitude: segment.start_latlng[1])
    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    self.displayedSegment = segment
    self.position = MapCameraPosition.region(region)
  }
}

#Preview {
  let user = User.createTestUser(withClubs: Club.createTestClubs())
  let authCtx = AuthContext(isLoggedIn: true, loggedInUser: user)
  @State var path = [Int]()
  return SegmentsView(path: $path)
    .environmentObject(authCtx)
    .environmentObject(LocationModel())
}
