//
//  Location.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
  static let sanFrancisco: Self = .init(
    latitude: 37.733795,
    longitude: -122.446747
  )
  
  var mapRect:MKMapRect {
    return MKMapRect(
      origin: MKMapPoint(.sanFrancisco),
      size: MKMapSize(width: 1, height: 1))
  }
}

/**
 attribution: https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
 */
class LocationModel: NSObject, CLLocationManagerDelegate, ObservableObject {
  @Published var authorizationStatus: CLAuthorizationStatus
  var lastSeenLocation: CLLocation?
  var currentPlacemark: CLPlacemark?
  
  private let locationManager: CLLocationManager
  
  override init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }
  
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let lastSeenLocation = self.lastSeenLocation,
       let newLocation = locations.first {
      let distance = lastSeenLocation.distance(from: newLocation)
//      print("distance=\(distance)")
      if distance > 100 {
        self.lastSeenLocation = newLocation
        fetchCountryAndCity(for: newLocation)
      }
    } else {
      lastSeenLocation = locations.first
      fetchCountryAndCity(for: locations.first)
    }
  }
  
  func fetchCountryAndCity(for location: CLLocation?) {
//    print("fetchCountryAndCity()")
    guard let location = location else { return }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      self.currentPlacemark = placemarks?.first
    }
  }
  
}
